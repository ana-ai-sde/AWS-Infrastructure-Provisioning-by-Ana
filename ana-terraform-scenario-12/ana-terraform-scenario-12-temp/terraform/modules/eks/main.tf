locals {
  name = var.cluster_name
  tags = {
    Environment = var.environment
    Terraform   = "true"
    Project     = var.project_name
  }
}

resource "aws_eks_cluster" "main" {
  name     = local.name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [aws_security_group.cluster.id]
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  tags = local.tags

  depends_on = [
    aws_cloudwatch_log_group.eks
  ]
}

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${local.name}/cluster"
  retention_in_days = 30

  tags = local.tags
}

# EKS Cluster Security Group
resource "aws_security_group" "cluster" {
  name        = "${local.name}-cluster"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id

  tags = merge(
    local.tags,
    {
      "Name" = "${local.name}-cluster"
    }
  )
}

# Worker Node Security Group
resource "aws_security_group" "workers" {
  name        = "${local.name}-workers"
  description = "Security group for worker nodes in EKS cluster"
  vpc_id      = var.vpc_id

  tags = merge(
    local.tags,
    {
      "Name" = "${local.name}-workers"
      "kubernetes.io/cluster/${local.name}" = "owned"
    }
  )
}

# Cluster Security Group Rules

# Allow worker nodes to communicate with the cluster API Server
resource "aws_security_group_rule" "cluster_api" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.workers.id
  to_port                  = 443
  type                     = "ingress"
}

# Allow cluster API Server to communicate with the worker nodes
resource "aws_security_group_rule" "cluster_to_nodes" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.workers.id
  to_port                  = 65535
  type                     = "ingress"
}

# Allow HTTPS egress from cluster to internet
resource "aws_security_group_rule" "cluster_egress" {
  description       = "Allow cluster egress access to the Internet"
  protocol          = "-1"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

# Worker Nodes Security Group Rules

# Allow nodes to communicate with each other
resource "aws_security_group_rule" "node_to_node" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.workers.id
  to_port                  = 65535
  type                     = "ingress"
}

# Allow worker nodes to communicate with cluster API Server
resource "aws_security_group_rule" "node_to_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster API Server"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

# Allow worker nodes outbound internet access
resource "aws_security_group_rule" "node_outbound" {
  description       = "Allow worker nodes outbound internet access"
  protocol          = "-1"
  security_group_id = aws_security_group.workers.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types

  update_config {
    max_unavailable = 1
  }

  labels = {
    "role" = "general"
  }

  tags = local.tags

  depends_on = [
    aws_eks_cluster.main
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

# OIDC Provider
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}