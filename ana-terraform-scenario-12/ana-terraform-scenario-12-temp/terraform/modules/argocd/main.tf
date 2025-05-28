locals {
  name = var.cluster_name
  tags = {
    Environment = var.environment
    Terraform   = "true"
    Project     = var.project_name
  }
}

# Create ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# Create AWS Secrets Manager secret for ArgoCD admin password
resource "random_password" "argocd_admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "argocd_admin_password" {
  name = "${local.name}-argocd-admin-password"
  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "argocd_admin_password" {
  secret_id     = aws_secretsmanager_secret.argocd_admin_password.id
  secret_string = random_password.argocd_admin_password.result
}

# Create OIDC provider IAM role for ArgoCD
data "aws_iam_policy_document" "argocd_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.argocd_namespace}:argocd-application-controller"]
    }

    principals {
      identifiers = [var.cluster_oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "argocd" {
  name               = "${local.name}-argocd-role"
  assume_role_policy = data.aws_iam_policy_document.argocd_assume_role.json
  tags               = local.tags
}

# ArgoCD IAM policy for accessing AWS resources
resource "aws_iam_role_policy" "argocd" {
  name = "${local.name}-argocd-policy"
  role = aws_iam_role.argocd.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.argocd_admin_password.arn
        ]
      }
    ]
  })
}

# Create Kubernetes service account for ArgoCD
resource "kubernetes_service_account" "argocd" {
  metadata {
    name      = "argocd-application-controller"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.argocd.arn
    }
  }
}

# Install ArgoCD using Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_helm_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    templatefile("${path.module}/values.yaml", {
      admin_password_secret_name = aws_secretsmanager_secret.argocd_admin_password.name
      namespace                  = var.argocd_namespace
      enable_dex                 = var.enable_dex
      oidc_config               = var.oidc_config
      repositories              = var.repositories
    })
  ]

  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_service_account.argocd,
    aws_secretsmanager_secret_version.argocd_admin_password
  ]
}

# Create ApplicationSet for system components
resource "kubectl_manifest" "system_appset" {
  yaml_body = templatefile("${path.module}/templates/system-appset.yaml", {
    namespace = var.argocd_namespace
    repo_url  = var.gitops_repo_url
    repo_path = var.gitops_repo_path
  })

  depends_on = [
    helm_release.argocd
  ]
}