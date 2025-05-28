variable "name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the SNS topic"
  type        = map(string)
  default     = {}
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK"
  type        = string
  default     = null
}

variable "policy" {
  description = "The fully-formed AWS policy as JSON"
  type        = string
  default     = null
}

variable "delivery_policy" {
  description = "The SNS delivery policy"
  type        = string
  default     = null
}

variable "fifo_topic" {
  description = "Boolean indicating whether or not to create a FIFO (first-in-first-out) topic"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO topics"
  type        = bool
  default     = false
}