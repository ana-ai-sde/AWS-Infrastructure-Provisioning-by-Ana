variable "environment" {
  description = "Environment name for tagging"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "metric_namespace" {
  description = "Namespace for CloudWatch metrics"
  type        = string
}

variable "log_group_name" {
  description = "Log group name for dashboard widgets"
  type        = string
}