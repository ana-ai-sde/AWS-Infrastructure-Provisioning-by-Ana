variable "public_subnet_id" {
  description = "ID of the public subnet where NAT Gateway will be created"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the NAT Gateway"
  type        = map(string)
  default     = {}
}