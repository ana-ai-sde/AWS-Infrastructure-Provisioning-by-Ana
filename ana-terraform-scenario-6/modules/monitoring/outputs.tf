output "sns_topic_arns" {
  description = "Map of SNS topic names to their ARNs"
  value       = { for k, v in aws_sns_topic.notifications : k => v.arn }
}

output "cloudwatch_alarms" {
  description = "Map of CloudWatch alarm names to their ARNs"
  value       = { for k, v in aws_cloudwatch_metric_alarm.alarms : k => v.arn }
}