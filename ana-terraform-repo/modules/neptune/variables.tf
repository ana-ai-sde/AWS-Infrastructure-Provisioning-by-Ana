variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where Neptune cluster will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where Neptune cluster can be created"
  type        = list(string)
}

variable "instance_class" {
  description = "Instance class to be used for Neptune instances"
  type        = string
  default     = "db.r5.large"
}

variable "neptune_cluster_size" {
  description = "Number of instances in the Neptune cluster"
  type        = number
  default     = 1
}

variable "neptune_port" {
  description = "Port for Neptune cluster"
  type        = number
  default     = 8182
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot should be created before the cluster is deleted"
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB cluster is deleted"
  type        = string
  default     = null
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately"
  type        = bool
  default     = false
}

variable "neptune_parameter_group_family" {
  description = "Family of Neptune parameter group"
  type        = string
  default     = "neptune1.2"
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created"
  type        = string
  default     = "03:00-04:00"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}