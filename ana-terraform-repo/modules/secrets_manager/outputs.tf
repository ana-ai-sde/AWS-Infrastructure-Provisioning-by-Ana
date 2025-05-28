output "secret_arns" {
  description = "Map of secret names to their ARNs"
  value       = { for k, v in aws_secretsmanager_secret.secrets : k => v.arn }
}

output "secret_ids" {
  description = "Map of secret names to their IDs"
  value       = { for k, v in aws_secretsmanager_secret.secrets : k => v.id }
}

output "vpc_endpoint_id" {
  description = "The ID of the VPC endpoint for Secrets Manager"
  value       = aws_vpc_endpoint.secrets.id
}

output "vpc_endpoint_dns_entry" {
  description = "The DNS entries for the VPC endpoint for Secrets Manager"
  value       = aws_vpc_endpoint.secrets.dns_entry
}

output "security_group_id" {
  description = "The ID of the security group for the Secrets Manager VPC endpoint"
  value       = aws_security_group.secrets.id
}

output "rotation_lambda_arn" {
  description = "The ARN of the Lambda function used for secret rotation (if enabled)"
  value       = var.enable_secret_rotation ? aws_lambda_function.rotation[0].arn : null
}

output "rotation_lambda_role_arn" {
  description = "The ARN of the IAM role used by the rotation Lambda function (if enabled)"
  value       = var.enable_secret_rotation ? aws_iam_role.rotation_lambda[0].arn : null
}

output "secret_versions" {
  description = "Map of secret names to their version IDs"
  value       = { for k, v in aws_secretsmanager_secret_version.secret_values : k => v.version_id }
}