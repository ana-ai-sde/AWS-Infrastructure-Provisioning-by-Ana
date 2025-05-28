variable "environment" {
  description = "Environment name"
  type        = string
}

variable "ami_id" {
  description = "ID of the AMI to use for the instances"
  type        = string
}

variable "instance_type" {
  description = "Type of instance to launch"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to associate"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs to launch resources in"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of target group ARNs to associate"
  type        = list(string)
  default     = []
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 4
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "user_data" {
  description = "User data to provide when launching the instances"
  type        = string
  default     = ""
}

variable "iam_role_name" {
  description = "Name of the IAM role to associate with the instances"
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "scale_up_cpu_threshold" {
  description = "CPU threshold to trigger scale up"
  type        = number
  default     = 80
}

variable "scale_down_cpu_threshold" {
  description = "CPU threshold to trigger scale down"
  type        = number
  default     = 30
}

variable "key_name" {
  description = "Name of the key pair to use for SSH access"
  type        = string
}