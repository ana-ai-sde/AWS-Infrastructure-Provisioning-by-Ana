variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the ML project"
  type        = string
  default     = "ml-self-healing"
}

variable "pipeline_name" {
  description = "Name of the SageMaker pipeline"
  type        = string
  default     = "training-pipeline"
}

variable "model_package_group_name" {
  description = "Name of the model package group"
  type        = string
  default     = "training-models"
}

variable "feature_groups" {
  description = "List of feature group configurations"
  type = list(object({
    name                           = string
    description                    = string
    record_identifier_feature_name = string
    event_time_feature_name        = string
    features = list(object({
      name = string
      type = string
    }))
  }))
  default = []
}