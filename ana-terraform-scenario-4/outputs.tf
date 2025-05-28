output "canary_name" {
  description = "Name of the created CloudWatch Synthetics canary"
  value       = module.synthetic_monitoring.canary_name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  value       = module.notification.sns_topic_arn
}

output "alarm_arn" {
  description = "ARN of the CloudWatch alarm"
  value       = module.alarm.alarm_arn
}

output "canary_s3_bucket" {
  description = "Name of the S3 bucket storing canary artifacts"
  value       = module.synthetic_monitoring.s3_bucket_name
}

output "canary_role_arn" {
  description = "ARN of the IAM role used by the canary"
  value       = module.synthetic_monitoring.canary_role_arn
}