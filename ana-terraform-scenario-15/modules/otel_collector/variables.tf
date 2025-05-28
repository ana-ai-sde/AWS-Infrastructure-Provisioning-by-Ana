variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "cluster_id" {
  description = "ID of the EKS cluster"
  type        = string
}

variable "tempo_endpoint" {
  description = "Endpoint for Tempo trace backend"
  type        = string
}

variable "loki_endpoint" {
  description = "Endpoint for Loki log backend"
  type        = string
}