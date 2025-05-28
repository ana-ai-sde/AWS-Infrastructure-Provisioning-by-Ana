variable "alarm_name" {
  description = "Name for the CloudWatch alarm"
  type        = string
}

variable "canary_name" {
  description = "Name of the CloudWatch Synthetics canary to monitor"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  type        = string
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate for the alarm"
  type        = number
  default     = 2
}

variable "threshold" {
  description = "The threshold for the alarm"
  type        = number
  default     = 90
}