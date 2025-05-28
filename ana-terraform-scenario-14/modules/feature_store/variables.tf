variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "feature_groups" {
  description = "List of feature group configurations"
  type = list(object({
    name        = string
    description = string
    record_identifier_feature_name = string
    event_time_feature_name       = string
    features = list(object({
      name = string
      type = string
    }))
  }))
}