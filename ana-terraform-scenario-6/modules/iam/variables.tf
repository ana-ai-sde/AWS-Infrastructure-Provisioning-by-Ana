variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., prod, dev, staging)"
  type        = string
}

variable "ec2_role_config" {
  description = "Configuration for EC2 instance role"
  type = object({
    enable_ssm       = bool
    enable_cloudwatch = bool
    custom_policies  = map(object({
      effect    = string
      actions   = list(string)
      resources = list(string)
    }))
  })
  default = {
    enable_ssm       = true
    enable_cloudwatch = true
    custom_policies  = {}
  }
}

variable "backup_role_config" {
  description = "Configuration for backup role"
  type = object({
    enabled = bool
    backup_resources = list(string)
    restore_resources = list(string)
  })
  default = {
    enabled = false
    backup_resources = []
    restore_resources = []
  }
}

variable "custom_roles" {
  description = "Map of custom IAM roles to create"
  type = map(object({
    trusted_services = list(string)
    custom_policies = map(object({
      effect    = string
      actions   = list(string)
      resources = list(string)
    }))
    managed_policy_arns = list(string)
  }))
  default = {}
}

variable "boundary_policy_config" {
  description = "Configuration for permissions boundary policy"
  type = object({
    enabled = bool
    allowed_services = list(string)
    denied_actions = list(string)
  })
  default = {
    enabled = false
    allowed_services = []
    denied_actions = []
  }
}

variable "tags" {
  description = "Additional tags for IAM resources"
  type        = map(string)
  default     = {}
}