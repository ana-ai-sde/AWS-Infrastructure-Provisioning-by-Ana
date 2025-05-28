variable "availability_zone" {
  description = "The AZ where the EBS volume will exist"
  type        = string
}

variable "size" {
  description = "The size of the drive in GiBs"
  type        = number
  default     = 20
}

variable "type" {
  description = "The type of EBS volume. Can be standard, gp2, gp3, io1, io2, sc1 or st1"
  type        = string
  default     = "gp3"
}

variable "encrypted" {
  description = "If true, the disk will be encrypted"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying kms_key_id, encrypted needs to be set to true"
  type        = string
  default     = null
}

variable "iops" {
  description = "The amount of IOPS to provision for the disk. Only valid for type io1, io2 and gp3"
  type        = number
  default     = null
}

variable "throughput" {
  description = "The throughput that the volume supports, in MiB/s. Only valid for type gp3"
  type        = number
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}