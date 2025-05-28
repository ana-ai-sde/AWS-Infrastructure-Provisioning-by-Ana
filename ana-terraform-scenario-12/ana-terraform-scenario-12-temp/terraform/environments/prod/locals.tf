locals {
  account_id    = "229132727554"
  cluster_name  = "${var.project_name}-${var.environment}"
  region        = var.aws_region

  # Common tags for all resources
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    AccountID   = local.account_id
  }

  # EKS specific configurations
  eks_managed_node_groups = {
    initial = {
      instance_types = var.instance_types
      min_size      = var.min_size
      max_size      = var.max_size
      desired_size  = var.desired_size
    }
  }

  # ECR repositories that will be created
  ecr_repositories = [
    "monitoring",
    "applications",
    "chaos"
  ]
}