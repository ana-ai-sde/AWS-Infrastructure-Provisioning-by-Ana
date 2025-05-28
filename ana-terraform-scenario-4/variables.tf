variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "url_to_monitor" {
  description = "URL to monitor with CloudWatch Synthetics"
  type        = string
  default     = "https://example.com"
}

variable "email_endpoints" {
  description = "List of email addresses to receive notifications"
  type        = list(string)
  default     = ["example@email.com"]
}