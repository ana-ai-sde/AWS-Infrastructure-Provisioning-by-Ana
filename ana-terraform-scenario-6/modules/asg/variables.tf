variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., prod, dev, staging)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ASG"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of target group ARNs for the ASG"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the instances"
  type        = list(string)
}

variable "instance_config" {
  description = "EC2 instance configuration"
  type = object({
    instance_type = string
    ami_id        = string
    key_name      = string
    user_data     = string
    root_volume = object({
      size              = number
      type              = string
      encrypted         = bool
      delete_on_termination = bool
    })
    ebs_volumes = list(object({
      device_name = string
      size        = number
      type        = string
      encrypted   = bool
    }))
  })
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
}

variable "scaling_policies" {
  description = "Auto scaling policies configuration"
  type = map(object({
    policy_type = string
    target_tracking = optional(object({
      target_value       = number
      disable_scale_in   = bool
      metric_name        = string
      namespace         = string
      statistic         = string
    }))
    step_scaling = optional(object({
      adjustment_type    = string
      cooldown          = number
      metric_interval_lower_bound = number
      metric_interval_upper_bound = number
      scaling_adjustment = number
    }))
  }))
  default = {}
}

variable "instance_refresh" {
  description = "Instance refresh configuration"
  type = object({
    enabled = bool
    strategy = string
    preferences = object({
      min_healthy_percentage = number
      instance_warmup       = number
      checkpoint_delay      = number
      checkpoint_percentages = list(number)
    })
    triggers = list(string)
  })
  default = {
    enabled = false
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 90
      instance_warmup       = 300
      checkpoint_delay      = 300
      checkpoint_percentages = [20, 40, 60, 80, 100]
    }
    triggers = ["tag"]
  }
}

variable "mixed_instances_policy" {
  description = "Mixed instances policy configuration"
  type = object({
    enabled = bool
    instances_distribution = object({
      on_demand_percentage_above_base_capacity = number
      spot_allocation_strategy                = string
      spot_instance_pools                    = number
      spot_max_price                         = string
    })
    override = list(object({
      instance_type     = string
      weighted_capacity = number
    }))
  })
  default = {
    enabled = false
    instances_distribution = {
      on_demand_percentage_above_base_capacity = 100
      spot_allocation_strategy                = "lowest-price"
      spot_instance_pools                    = 2
      spot_max_price                         = ""
    }
    override = []
  }
}

variable "monitoring_config" {
  description = "CloudWatch monitoring configuration"
  type = map(object({
    metric_name         = string
    namespace          = string
    statistic          = string
    comparison_operator = string
    threshold          = number
    period             = number
    evaluation_periods = number
    alarm_actions      = list(string)
    dimensions         = map(string)
  }))
  default = {}
}

variable "tags" {
  description = "Additional tags for ASG resources"
  type        = map(string)
  default     = {}
}