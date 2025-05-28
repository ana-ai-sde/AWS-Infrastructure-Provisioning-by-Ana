variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where Aurora cluster will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where Aurora cluster can be created"
  type        = list(string)
}

variable "instance_class" {
  description = "Instance class to be used for Aurora instances"
  type        = string
  default     = "db.r5.large"
}

variable "engine" {
  description = "Aurora database engine (mysql or postgresql)"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version" {
  description = "Aurora database engine version"
  type        = string
  default     = "15.3"
}

variable "database_name" {
  description = "Name of the default database to create"
  type        = string
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
}

variable "master_password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
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

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot should be created before the cluster is deleted"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "If the cluster should have deletion protection enabled"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately"
  type        = bool
  default     = false
}

variable "replica_count" {
  description = "Number of reader nodes to create"
  type        = number
  default     = 1
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}