resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.alarm_threshold
  alarm_description   = "This metric monitors EC2 CPU utilization"
  alarm_actions      = [var.sns_topic_arn]
  
  # Missing data handling configuration
  treat_missing_data = "breaching"  # Treat missing data as breaching the threshold
  insufficient_data_actions = [var.sns_topic_arn]  # Send notification when there's insufficient data
  datapoints_to_alarm = 2  # Number of datapoints that must be breaching to trigger the alarm

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = {
    Name = "High CPU Utilization Alarm"
    Purpose = "SRE Automated Response"
  }
}

# Additional alarm for instance status check
resource "aws_cloudwatch_metric_alarm" "instance_status_check" {
  alarm_name          = "instance-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "This metric monitors EC2 instance status checks"
  alarm_actions      = [var.sns_topic_arn]
  
  treat_missing_data = "breaching"
  insufficient_data_actions = [var.sns_topic_arn]
  datapoints_to_alarm = 2

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = {
    Name = "Instance Status Check Alarm"
    Purpose = "SRE Automated Response"
  }
}