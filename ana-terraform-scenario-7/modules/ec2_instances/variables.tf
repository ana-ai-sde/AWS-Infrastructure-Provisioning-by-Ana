variable "environment" {
  description = "Environment name for tagging"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 2
}

variable "subnet_ids" {
  description = "List of subnet IDs for the instances"
  type        = list(string)
}

variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to SSH into instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cloudwatch_agent_profile_name" {
  description = "Name of the CloudWatch Agent instance profile"
  type        = string
}

variable "cloudwatch_agent_config_param" {
  description = "SSM Parameter name for CloudWatch Agent configuration"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}