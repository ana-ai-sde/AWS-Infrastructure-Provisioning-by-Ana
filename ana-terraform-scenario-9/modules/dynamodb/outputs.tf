output "table_name" {
  description = "Name of the created DynamoDB table"
  value       = aws_dynamodb_table.main.name
}

output "table_arn" {
  description = "ARN of the created DynamoDB table"
  value       = aws_dynamodb_table.main.arn
}

output "billing_mode" {
  description = "Billing mode of the DynamoDB table"
  value       = aws_dynamodb_table.main.billing_mode
}

output "read_capacity" {
  description = "Read capacity of the DynamoDB table (if PROVISIONED)"
  value       = local.is_provisioned ? aws_dynamodb_table.main.read_capacity : null
}

output "write_capacity" {
  description = "Write capacity of the DynamoDB table (if PROVISIONED)"
  value       = local.is_provisioned ? aws_dynamodb_table.main.write_capacity : null
}