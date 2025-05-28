output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = module.notification_topic.topic_arn
}

output "sns_topic_id" {
  description = "ID of the SNS topic"
  value       = module.notification_topic.topic_id
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = module.notification_topic.topic_name
}