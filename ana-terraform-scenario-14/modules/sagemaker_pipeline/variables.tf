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

variable "model_package_group_name" {
  description = "Name of the model package group"
  type        = string
}

variable "feature_group_names" {
  description = "List of feature group names"
  type        = list(string)
}