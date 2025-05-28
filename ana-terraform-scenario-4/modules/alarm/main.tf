resource "aws_cloudwatch_metric_alarm" "canary_alarm" {
  alarm_name          = var.alarm_name
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "SuccessPercent"
  namespace          = "CloudWatchSynthetics"
  period             = "300"
  statistic          = "Average"
  threshold          = var.threshold
  alarm_description  = "Alarm when URL health check fails"
  alarm_actions      = [var.sns_topic_arn]
  ok_actions         = [var.sns_topic_arn]

  dimensions = {
    CanaryName = var.canary_name
  }
}