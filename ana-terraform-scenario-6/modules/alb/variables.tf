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

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "target_group_port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol to use for routing traffic to the targets"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Type of target that you must specify when registering targets"
  type        = string
  default     = "instance"
}

variable "health_check" {
  description = "Health check configuration for target group"
  type = object({
    enabled             = bool
    path                = string
    port                = string
    protocol            = string
    timeout             = number
    interval            = number
    healthy_threshold   = number
    unhealthy_threshold = number
    matcher             = string
  })
  default = {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

variable "stickiness" {
  description = "Target group stickiness configuration"
  type = object({
    enabled         = bool
    type            = string
    cookie_duration = number
  })
  default = {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 86400
  }
}

variable "ssl_configuration" {
  description = "SSL configuration for HTTPS listener"
  type = object({
    certificate_arn = string
    ssl_policy     = string
  })
  default = {
    certificate_arn = ""
    ssl_policy     = "ELBSecurityPolicy-TLS-1-2-2017-01"
  }
}

variable "access_logs" {
  description = "Access logs configuration for ALB"
  type = object({
    enabled = bool
    bucket  = string
    prefix  = string
  })
  default = {
    enabled = false
    bucket  = ""
    prefix  = ""
  }
}

variable "alb_settings" {
  description = "General ALB settings"
  type = object({
    internal                   = bool
    enable_deletion_protection = bool
    enable_http2              = bool
    idle_timeout              = number
  })
  default = {
    internal                   = false
    enable_deletion_protection = true
    enable_http2              = true
    idle_timeout              = 60
  }
}

variable "alarm_actions" {
  description = "List of ARNs of actions to take when alarms are triggered"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for ALB resources"
  type        = map(string)
  default     = {}
}