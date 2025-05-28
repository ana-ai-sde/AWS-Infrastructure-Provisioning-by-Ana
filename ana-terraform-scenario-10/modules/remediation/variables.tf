variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "instance_id" {
  description = "ID of the EC2 instance to remediate"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  type        = string
}