variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "ap-south-1"
}

variable "notification_emails" {
  description = "List of email addresses for notifications"
  type        = list(string)
}

variable "cpu_threshold" {
  description = "CPU threshold percentage to trigger alarm"
  type        = number
  default     = 80
}