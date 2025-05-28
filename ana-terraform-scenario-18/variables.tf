variable "primary_region" {
  description = "Primary AWS region for VPN deployment (Mumbai)"
  type        = string
  default     = "ap-south-1"
}

variable "secondary_region" {
  description = "Secondary AWS region for VPN failover (N. Virginia)"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_primary" {
  description = "CIDR block for primary VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_cidr_secondary" {
  description = "CIDR block for secondary VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "vpn_bgp_asn" {
  description = "BGP ASN for primary region Transit Gateway"
  type        = number
  default     = 65000
}

variable "vpn_bgp_asn_secondary" {
  description = "BGP ASN for secondary region Transit Gateway"
  type        = number
  default     = 65001
}

variable "customer_gateway_asn_primary" {
  description = "BGP ASN for primary region Customer Gateways"
  type        = number
  default     = 65002
}

variable "customer_gateway_asn_secondary" {
  description = "BGP ASN for secondary region Customer Gateways"
  type        = number
  default     = 65003
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "production"
}

variable "strongswan_instance_type" {
  description = "EC2 instance type for StrongSwan CGW"
  type        = string
  default     = "t3.medium"
}