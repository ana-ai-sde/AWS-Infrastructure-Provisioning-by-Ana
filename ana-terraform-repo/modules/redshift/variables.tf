variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where Redshift cluster will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where Redshift cluster can be created"
  type        = list(string)
}

variable "node_type" {
  description = "The node type to be provisioned for the cluster"
  type        = string
  default     = "dc2.large"
}

variable "cluster_type" {
  description = "The cluster type to create (single-node or multi-node)"
  type        = string
  default     = "multi-node"
}

variable "number_of_nodes" {
  description = "Number of nodes in the cluster (ignored for single-node cluster_type)"
  type        = number
  default     = 2
}

variable "database_name" {
  description = "Name of the first database to be created"
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

variable "port" {
  description = "The port number on which the cluster accepts incoming connections"
  type        = number
  default     = 5439
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot should be created before the cluster is deleted"
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "The identifier of the final snapshot that is to be created immediately before deleting the cluster"
  type        = string
  default     = null
}

variable "automated_snapshot_retention_period" {
  description = "The number of days that automated snapshots are retained"
  type        = number
  default     = 7
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "allow_version_upgrade" {
  description = "If true, major version upgrades can be applied during maintenance window"
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "If true, the cluster can be accessed from a public network"
  type        = bool
  default     = false
}

variable "encrypted" {
  description = "If true, the data in the cluster is encrypted at rest"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying kms_key_id, encrypted needs to be set to true"
  type        = string
  default     = null
}

variable "elastic_ip" {
  description = "If true, the cluster is assigned an Elastic IP address"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}