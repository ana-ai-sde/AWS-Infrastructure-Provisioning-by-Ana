output "topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.this.arn
}

output "topic_id" {
  description = "The ID of the SNS topic"
  value       = aws_sns_topic.this.id
}

output "topic_name" {
  description = "The name of the SNS topic"
  value       = aws_sns_topic.this.name
}