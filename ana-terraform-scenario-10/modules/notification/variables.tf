variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "email_addresses" {
  description = "List of email addresses to subscribe to the SNS topic"
  type        = list(string)
  validation {
    condition     = length(var.email_addresses) > 0
    error_message = "At least one email address must be provided."
  }
  validation {
    condition     = alltrue([for email in var.email_addresses : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))])
    error_message = "All email addresses must be in a valid format."
  }
}