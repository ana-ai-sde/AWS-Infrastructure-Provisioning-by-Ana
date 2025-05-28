provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Terraform   = "true"
      Project     = var.project_name
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    }
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  cluster_name = local.cluster_name
  environment  = var.environment
  project_name = var.project_name

  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  private_subnets    = var.private_subnet_cidrs
  public_subnets     = var.public_subnet_cidrs
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

  cluster_name  = local.cluster_name
  environment   = var.environment
  project_name  = var.project_name
}

# EKS Module
module "eks" {
  source = "../../modules/eks"

  cluster_name       = local.cluster_name
  environment        = var.environment
  project_name       = var.project_name
  kubernetes_version = var.kubernetes_version

  cluster_role_arn    = module.iam.cluster_role_arn
  node_role_arn       = module.iam.node_role_arn
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids

  desired_size    = var.desired_size
  min_size        = var.min_size
  max_size        = var.max_size
  instance_types  = var.instance_types
}

# ArgoCD Module
module "argocd" {
  source = "../../modules/argocd"

  cluster_name              = local.cluster_name
  environment              = var.environment
  project_name             = var.project_name
  cluster_oidc_issuer_url  = module.eks.cluster_oidc_issuer_url
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn

  gitops_repo_url = var.gitops_repo_url
  
  # Optional configurations
  enable_dex    = var.enable_dex
  oidc_config   = var.oidc_config
  repositories  = var.repository_configs

  depends_on = [
    module.eks
  ]
}