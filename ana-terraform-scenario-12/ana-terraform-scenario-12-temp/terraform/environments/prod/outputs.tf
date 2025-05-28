output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.iam.cluster_role_arn
}

output "argocd_admin_password_secret" {
  description = "Name of the AWS Secrets Manager secret containing ArgoCD admin password"
  value       = module.argocd.admin_password_secret_name
}

output "argocd_url" {
  description = "URL where ArgoCD UI is available"
  value       = module.argocd.argocd_url
}