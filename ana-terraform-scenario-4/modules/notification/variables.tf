variable "sns_topic_name" {
  description = "Name for the SNS topic"
  type        = string
}

variable "email_endpoints" {
  description = "List of email addresses to receive notifications"
  type        = list(string)
}