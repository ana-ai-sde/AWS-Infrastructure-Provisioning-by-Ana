output "sns_topic_arn" {
  description = "ARN of the created SNS topic"
  value       = aws_sns_topic.monitoring_alerts.arn
}

output "sns_topic_name" {
  description = "Name of the created SNS topic"
  value       = aws_sns_topic.monitoring_alerts.name
}