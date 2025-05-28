output "canary_name" {
  description = "Name of the created CloudWatch Synthetics canary"
  value       = aws_synthetics_canary.url_monitor.name
}

output "canary_arn" {
  description = "ARN of the created CloudWatch Synthetics canary"
  value       = aws_synthetics_canary.url_monitor.arn
}

output "canary_role_arn" {
  description = "ARN of the IAM role used by the canary"
  value       = aws_iam_role.canary_role.arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket storing canary artifacts"
  value       = aws_s3_bucket.canary_bucket.id
}