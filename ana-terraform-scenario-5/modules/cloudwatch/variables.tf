variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain Lambda logs"
  type        = number
  default     = 14
}