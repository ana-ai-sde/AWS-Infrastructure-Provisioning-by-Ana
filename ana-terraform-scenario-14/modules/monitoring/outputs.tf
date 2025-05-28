output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home#dashboards:name=${aws_cloudwatch_dashboard.ml_dashboard.dashboard_name}"
}

output "monitoring_bucket" {
  description = "Name of the monitoring S3 bucket"
  value       = aws_s3_bucket.monitoring.id
}

output "monitoring_role_arn" {
  description = "ARN of the monitoring IAM role"
  value       = aws_iam_role.monitoring_role.arn
}