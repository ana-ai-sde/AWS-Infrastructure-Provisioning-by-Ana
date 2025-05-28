variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  type        = string
}