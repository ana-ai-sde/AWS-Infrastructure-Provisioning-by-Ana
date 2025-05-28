variable "creation_token" {
  description = "A unique name for the EFS file system"
  type        = string
}

variable "performance_mode" {
  description = "The file system performance mode. Can be either 'generalPurpose' or 'maxIO'"
  type        = string
  default     = "generalPurpose"
}

variable "throughput_mode" {
  description = "The throughput mode for the file system. Can be 'bursting' or 'provisioned'"
  type        = string
  default     = "bursting"
}

variable "provisioned_throughput_in_mibps" {
  description = "The throughput, measured in MiB/s, that you want to provision for the file system"
  type        = number
  default     = null
}

variable "encrypted" {
  description = "If true, the disk will be encrypted"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID where the EFS will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where EFS mount targets will be created"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to the EFS file system"
  type        = map(string)
  default     = {}
}