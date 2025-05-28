variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "pipeline_name" {
  description = "Name of the SageMaker pipeline"
  type        = string
}

variable "endpoint_name" {
  description = "Name of the SageMaker endpoint"
  type        = string
}

variable "alert_sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  type        = string
}