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

  # Combine all metrics for alarms
  all_metrics = merge(
    var.ec2_monitoring.enabled ? {
      for k, v in var.ec2_monitoring.metrics : "ec2-${k}" => merge(v, {
        dimensions = var.ec2_monitoring.dimensions
      })
    } : {},
    var.rds_monitoring.enabled ? {
      for k, v in var.rds_monitoring.metrics : "rds-${k}" => merge(v, {
        dimensions = var.rds_monitoring.dimensions
      })
    } : {},
    var.alb_monitoring.enabled ? {
      for k, v in var.alb_monitoring.metrics : "alb-${k}" => merge(v, {
        dimensions = var.alb_monitoring.dimensions
      })
    } : {}
  )
}

# SNS Topics for Notifications
resource "aws_sns_topic" "notifications" {
  for_each = var.alarm_notification_config.enabled ? var.alarm_notification_config.endpoints : {}

  name = "${local.name_prefix}-${each.key}"
  tags = local.default_tags
}

resource "aws_sns_topic_subscription" "notifications" {
  for_each = var.alarm_notification_config.enabled ? var.alarm_notification_config.endpoints : {}

  topic_arn = aws_sns_topic.notifications[each.key].arn
  protocol  = each.value.type
  endpoint  = each.value.endpoint
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "alarms" {
  for_each = local.all_metrics

  alarm_name          = "${local.name_prefix}-${each.key}"
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  datapoints_to_alarm = each.value.datapoints_to_alarm
  treat_missing_data  = each.value.treat_missing_data

  dimensions = each.value.dimensions

  alarm_description = "Alarm for ${each.key}"
  alarm_actions     = concat(
    each.value.actions,
    var.alarm_notification_config.default_actions
  )

  tags = local.default_tags
}