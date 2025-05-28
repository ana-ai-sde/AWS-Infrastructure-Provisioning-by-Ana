variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "onprem_public_ip" {
  description = "Public IP of on-premises VPN endpoint"
  type        = string
}

variable "onprem_cidr" {
  description = "CIDR block for on-premises network"
  type        = string
}

variable "private_route_table_id" {
  description = "ID of private route table"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}