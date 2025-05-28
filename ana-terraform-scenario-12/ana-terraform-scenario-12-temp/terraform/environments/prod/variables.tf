# General Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

# EKS Variables
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.27"
}

variable "desired_size" {
  description = "Desired size of the node group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum size of the node group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of the node group"
  type        = number
  default     = 4
}

variable "instance_types" {
  description = "List of instance types for the node group"
  type        = list(string)
  default     = ["t3.medium"]
}

# ArgoCD Variables
variable "gitops_repo_url" {
  description = "URL of the GitOps repository"
  type        = string
}

variable "enable_dex" {
  description = "Enable Dex for OIDC authentication"
  type        = bool
  default     = false
}

variable "oidc_config" {
  description = "OIDC configuration for Dex"
  type        = string
  default     = ""
}

variable "repository_configs" {
  description = "ArgoCD repository configurations"
  type        = string
  default     = ""
}