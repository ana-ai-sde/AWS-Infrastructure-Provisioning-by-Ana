variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "description" {
  description = "Description for the Transit Gateway"
  type        = string
}

variable "amazon_side_asn" {
  description = "BGP ASN for Transit Gateway"
  type        = number
}

variable "vpc_id" {
  description = "VPC ID to attach to the Transit Gateway"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for Transit Gateway attachment"
  type        = list(string)
}

variable "create_peering" {
  description = "Whether to create TGW peering (true for primary, false for secondary)"
  type        = bool
  default     = false
}

variable "peer_tgw_id" {
  description = "ID of the peer Transit Gateway for peering"
  type        = string
  default     = null
}

variable "peer_account_id" {
  description = "Account ID of the peer Transit Gateway"
  type        = string
  default     = null
}

variable "peer_region" {
  description = "Region of the peer Transit Gateway"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}