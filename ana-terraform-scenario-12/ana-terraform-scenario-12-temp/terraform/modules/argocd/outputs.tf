output "argocd_namespace" {
  description = "The Kubernetes namespace ArgoCD is deployed in"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_url" {
  description = "The URL where ArgoCD UI is available"
  value       = "https://argocd.internal"
}

output "admin_password_secret_name" {
  description = "Name of the AWS Secrets Manager secret containing ArgoCD admin password"
  value       = aws_secretsmanager_secret.argocd_admin_password.name
}

output "argocd_role_arn" {
  description = "ARN of the IAM role used by ArgoCD"
  value       = aws_iam_role.argocd.arn
}