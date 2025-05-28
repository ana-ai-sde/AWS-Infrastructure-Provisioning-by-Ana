output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.api_endpoint
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.lambda.function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = module.lambda.function_arn
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = module.dynamodb.table_arn
}

output "cloudwatch_dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = module.observability.dashboard_url
}

output "alarm_topic_arn" {
  description = "ARN of the SNS topic for alarms (if email was provided)"
  value       = module.observability.alarm_topic_arn
}

output "api_invoke_url" {
  description = "Base URL for API Gateway stage"
  value       = module.api_gateway.api_endpoint
}

output "load_test_command" {
  description = "Command to run the load test"
  value       = "API_ENDPOINT=${module.api_gateway.api_endpoint} npm test"
}