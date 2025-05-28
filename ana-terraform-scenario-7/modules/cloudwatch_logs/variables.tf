variable "environment" {
  description = "Environment name for tagging"
  type        = string
}

variable "retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}