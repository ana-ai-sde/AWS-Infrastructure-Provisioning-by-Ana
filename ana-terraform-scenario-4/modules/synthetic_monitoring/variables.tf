variable "monitoring_name" {
  description = "Name for the synthetic monitoring resources"
  type        = string
}

variable "url_to_monitor" {
  description = "URL to monitor with CloudWatch Synthetics"
  type        = string
}

variable "schedule_expression" {
  description = "Schedule expression for running the canary"
  type        = string
  default     = "rate(5 minutes)"
}