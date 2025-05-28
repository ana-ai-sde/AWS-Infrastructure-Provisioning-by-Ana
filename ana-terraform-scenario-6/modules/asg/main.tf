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

# Launch Template
resource "aws_launch_template" "main" {
  name_prefix = "${local.name_prefix}-lt"

  image_id      = var.instance_config.ami_id
  instance_type = var.instance_config.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = var.security_group_ids
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.instance_config.root_volume.size
      volume_type           = var.instance_config.root_volume.type
      encrypted            = var.instance_config.root_volume.encrypted
      delete_on_termination = var.instance_config.root_volume.delete_on_termination
    }
  }

  dynamic "block_device_mappings" {
    for_each = var.instance_config.ebs_volumes
    content {
      device_name = block_device_mappings.value.device_name

      ebs {
        volume_size = block_device_mappings.value.size
        volume_type = block_device_mappings.value.type
        encrypted   = block_device_mappings.value.encrypted
      }
    }
  }

  user_data = base64encode(var.instance_config.user_data)

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = local.default_tags
  }

  tag_specifications {
    resource_type = "volume"
    tags = local.default_tags
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name_prefix               = "${local.name_prefix}-asg"
  vpc_zone_identifier      = var.subnet_ids
  target_group_arns        = var.target_group_arns
  health_check_type        = var.asg_config.health_check_type
  health_check_grace_period = var.asg_config.health_check_grace_period
  default_cooldown         = var.asg_config.default_cooldown
  min_size                = var.asg_config.min_size
  max_size                = var.asg_config.max_size
  desired_capacity        = var.asg_config.desired_capacity
  termination_policies    = var.asg_config.termination_policies
  protect_from_scale_in   = var.asg_config.protect_from_scale_in
  max_instance_lifetime   = var.asg_config.max_instance_lifetime
  capacity_rebalance      = var.asg_config.capacity_rebalance

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  dynamic "warm_pool" {
    for_each = var.asg_config.warm_pool.enabled ? [1] : []
    content {
      pool_state                  = var.asg_config.warm_pool.pool_state
      min_size                    = var.asg_config.warm_pool.min_size
      max_group_prepared_capacity = var.asg_config.warm_pool.max_group_prepared_capacity
    }
  }

  dynamic "mixed_instances_policy" {
    for_each = var.mixed_instances_policy.enabled ? [1] : []
    content {
      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.main.id
          version           = "$Latest"
        }

        dynamic "override" {
          for_each = var.mixed_instances_policy.override
          content {
            instance_type     = override.value.instance_type
            weighted_capacity = override.value.weighted_capacity
          }
        }
      }

      instances_distribution {
        on_demand_percentage_above_base_capacity = var.mixed_instances_policy.instances_distribution.on_demand_percentage_above_base_capacity
        spot_allocation_strategy                = var.mixed_instances_policy.instances_distribution.spot_allocation_strategy
        spot_instance_pools                    = var.mixed_instances_policy.instances_distribution.spot_instance_pools
        spot_max_price                         = var.mixed_instances_policy.instances_distribution.spot_max_price
      }
    }
  }

  dynamic "instance_refresh" {
    for_each = var.instance_refresh.enabled ? [1] : []
    content {
      strategy = var.instance_refresh.strategy
      preferences {
        min_healthy_percentage = var.instance_refresh.preferences.min_healthy_percentage
        instance_warmup       = var.instance_refresh.preferences.instance_warmup
        checkpoint_delay      = var.instance_refresh.preferences.checkpoint_delay
        checkpoint_percentages = var.instance_refresh.preferences.checkpoint_percentages
      }
      triggers = var.instance_refresh.triggers
    }
  }

  dynamic "tag" {
    for_each = local.default_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "policies" {
  for_each = var.scaling_policies

  name                   = "${local.name_prefix}-${each.key}"
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type           = each.value.policy_type

  dynamic "target_tracking_configuration" {
    for_each = each.value.policy_type == "TargetTrackingScaling" ? [each.value.target_tracking] : []
    content {
      target_value     = target_tracking_configuration.value.target_value
      disable_scale_in = target_tracking_configuration.value.disable_scale_in

      customized_metric_specification {
        metric_name = target_tracking_configuration.value.metric_name
        namespace   = target_tracking_configuration.value.namespace
        statistic   = target_tracking_configuration.value.statistic
      }
    }
  }

  dynamic "step_adjustment" {
    for_each = each.value.policy_type == "StepScaling" ? [each.value.step_scaling] : []
    content {
      scaling_adjustment          = step_adjustment.value.scaling_adjustment
      metric_interval_lower_bound = step_adjustment.value.metric_interval_lower_bound
      metric_interval_upper_bound = step_adjustment.value.metric_interval_upper_bound
    }
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "alarms" {
  for_each = var.monitoring_config

  alarm_name          = "${local.name_prefix}-${each.key}"
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = "Auto Scaling ${each.key} alarm"
  alarm_actions       = each.value.alarm_actions
  dimensions          = each.value.dimensions

  tags = local.default_tags
}