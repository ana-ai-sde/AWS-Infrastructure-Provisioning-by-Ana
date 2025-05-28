output "sns_topic_arn" {
  description = "ARN of the created SNS topic"
  value       = aws_sns_topic.sre_alerts.arn
}

output "sns_topic_name" {
  description = "Name of the created SNS topic"
  value       = aws_sns_topic.sre_alerts.name
}

output "subscription_emails" {
  description = "Map of email subscriptions created"
  value       = { for k, v in aws_sns_topic_subscription.email_subscriptions : k => v.endpoint }
}