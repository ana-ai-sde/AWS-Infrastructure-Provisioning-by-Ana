variable "environment" {
  description = "Environment name for tagging"
  type        = string
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}