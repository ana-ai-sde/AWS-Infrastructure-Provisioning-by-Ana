variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "vpn_connection_id" {
  description = "ID of the VPN connection to monitor"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}