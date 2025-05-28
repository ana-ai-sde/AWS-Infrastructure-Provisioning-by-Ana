variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., prod, dev, staging)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "asg_config" {
  description = "Auto Scaling Group configuration"
  type = object({
    min_size                  = number
    max_size                  = number
    desired_capacity         = number
    health_check_type        = string
    health_check_grace_period = number
    default_cooldown         = number
    termination_policies     = list(string)
    protect_from_scale_in    = bool
    max_instance_lifetime    = number
    capacity_rebalance       = bool
    warm_pool = object({
      enabled = bool
      min_size = number
      max_group_prepared_capacity = number
      pool_state = string
    })
  })
  default = {
    min_size                  = 2
    max_size                  = 4
    desired_capacity         = 2
    health_check_type        = "ELB"
    health_check_grace_period = 300
    default_cooldown         = 300
    termination_policies     = ["OldestLaunchTemplate", "OldestInstance"]
    protect_from_scale_in    = false
    max_instance_lifetime    = 604800
    capacity_rebalance       = true
    warm_pool = {
      enabled = false
      min_size = 0
      max_group_prepared_capacity = 0
      pool_state = "Stopped"
    }
  }
}

variable "db_config" {
  description = "Database configuration"
  type = object({
    engine                  = string
    engine_version         = string
    instance_class         = string
    allocated_storage      = number
    max_allocated_storage  = number
    storage_type           = string
    storage_encrypted      = bool
    username              = string
    port                  = number
    db_name               = string
    parameter_group_family = string
  })
  default = {
    engine                  = "postgres"
    engine_version         = "13.10"
    instance_class         = "db.t3.medium"
    allocated_storage      = 20
    max_allocated_storage  = 100
    storage_type           = "gp3"
    storage_encrypted      = true
    username              = "dbadmin"
    port                  = 5432
    db_name               = "appdb"
    parameter_group_family = "postgres13"
  }
}

variable "alarm_email" {
  description = "Email address for alarm notifications"
  type        = string
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}