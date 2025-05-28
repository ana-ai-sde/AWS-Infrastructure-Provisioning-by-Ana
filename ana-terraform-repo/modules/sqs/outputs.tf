output "queue_id" {
  description = "The URL for the created Amazon SQS queue"
  value       = aws_sqs_queue.this.id
}

output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.this.arn
}

output "queue_name" {
  description = "The name of the SQS queue"
  value       = aws_sqs_queue.this.name
}

output "dlq_id" {
  description = "The URL for the created Amazon SQS dead-letter queue"
  value       = var.dlq_enabled ? aws_sqs_queue.dlq[0].id : null
}

output "dlq_arn" {
  description = "The ARN of the SQS dead-letter queue"
  value       = var.dlq_enabled ? aws_sqs_queue.dlq[0].arn : null
}

output "dlq_name" {
  description = "The name of the SQS dead-letter queue"
  value       = var.dlq_enabled ? aws_sqs_queue.dlq[0].name : null
}

output "queue_policy_id" {
  description = "The ID of the queue policy"
  value       = aws_sqs_queue_policy.this.id
}