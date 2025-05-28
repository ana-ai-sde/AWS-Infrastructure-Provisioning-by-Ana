variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = ""
}

variable "assume_role_policy" {
  description = "Assume role policy document in JSON format"
  type        = string
}

variable "policy_arns" {
  description = "List of policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "inline_policy" {
  description = "Inline policy document in JSON format"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to be applied to the IAM role"
  type        = map(string)
  default     = {}
}