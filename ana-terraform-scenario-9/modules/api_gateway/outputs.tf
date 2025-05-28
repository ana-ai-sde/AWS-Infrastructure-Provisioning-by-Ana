output "api_id" {
  description = "ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.api.id
}

output "api_name" {
  description = "Name of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.api.name
}

output "api_endpoint" {
  description = "Endpoint URL of the API Gateway"
  value       = "${aws_api_gateway_stage.stage.invoke_url}/items"
}

output "execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.api.execution_arn
}

output "cloudwatch_role_arn" {
  description = "ARN of the CloudWatch role"
  value       = aws_iam_role.cloudwatch.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.api_logs.name
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.stage.stage_name
}