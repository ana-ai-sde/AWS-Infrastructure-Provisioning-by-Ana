variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Secrets Manager endpoint"
  type        = list(string)
}

variable "kms_key_id" {
  description = "ARN of KMS key for encryption (optional)"
  type        = string
  default     = null
}

variable "recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret"
  type        = number
  default     = 7
}

variable "secrets" {
  description = "Map of secrets to create"
  type = map(object({
    description = string
    secret_string = object({
      username = string
      password = string
      engine   = optional(string)
      host     = optional(string)
      port     = optional(number)
      dbname   = optional(string)
    })
  }))
}

variable "enable_secret_rotation" {
  description = "Enable automatic secret rotation"
  type        = bool
  default     = false
}

variable "rotation_days" {
  description = "Number of days between automatic scheduled rotations"
  type        = number
  default     = 30
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}