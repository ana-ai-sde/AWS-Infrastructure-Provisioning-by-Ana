variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "customer_gateway_asn" {
  description = "BGP ASN for Customer Gateway"
  type        = number
}

variable "customer_gateway_ip" {
  description = "Public IP address of Customer Gateway"
  type        = string
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  type        = string
}

variable "tunnel1_inside_cidr" {
  description = "Inside CIDR for the first tunnel"
  type        = string
  default     = null
}

variable "tunnel2_inside_cidr" {
  description = "Inside CIDR for the second tunnel"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}