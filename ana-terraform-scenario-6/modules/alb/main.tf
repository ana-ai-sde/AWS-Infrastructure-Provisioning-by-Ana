locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  default_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  )
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = var.alb_settings.internal
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.alb_settings.enable_deletion_protection
  enable_http2              = var.alb_settings.enable_http2
  idle_timeout              = var.alb_settings.idle_timeout

  dynamic "access_logs" {
    for_each = var.access_logs.enabled ? [1] : []
    content {
      bucket  = var.access_logs.bucket
      prefix  = var.access_logs.prefix
      enabled = true
    }
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-alb"
    }
  )
}

# Target Group
resource "aws_lb_target_group" "main" {
  name        = "${local.name_prefix}-tg"
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    enabled             = var.health_check.enabled
    path                = var.health_check.path
    port                = var.health_check.port
    protocol            = var.health_check.protocol
    timeout             = var.health_check.timeout
    interval            = var.health_check.interval
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
    matcher             = var.health_check.matcher
  }

  dynamic "stickiness" {
    for_each = var.stickiness.enabled ? [1] : []
    content {
      type            = var.stickiness.type
      cookie_duration = var.stickiness.cookie_duration
      enabled         = true
    }
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-tg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = var.ssl_configuration.certificate_arn != "" ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.ssl_configuration.certificate_arn != "" ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "forward" {
      for_each = var.ssl_configuration.certificate_arn == "" ? [1] : []
      content {
        target_group {
          arn = aws_lb_target_group.main.arn
        }
      }
    }
  }
}

# HTTPS Listener (if certificate is provided)
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_configuration.ssl_policy
  certificate_arn   = var.ssl_configuration.certificate_arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  lifecycle {
    precondition {
      condition     = var.ssl_configuration.certificate_arn != ""
      error_message = "HTTPS listener requires a valid certificate ARN"
    }
  }
}