# SNS Topic for alarm notifications
resource "aws_sns_topic" "alarm_topic" {
  name = "cloudwatch-alarms-${var.environment}"

  tags = {
    Environment = var.environment
  }
}

# SNS Topic Email Subscription
resource "aws_sns_topic_subscription" "alarm_subscription" {
  count     = length(var.alarm_email_endpoints)
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alarm_email_endpoints[count.index]
}

# Anomaly Detection Alarm for CPU
resource "aws_cloudwatch_metric_alarm" "cpu_anomaly" {
  alarm_name                = "cpu-utilization-anomaly-${var.environment}"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods       = var.cpu_anomaly_config.evaluation_periods
  threshold_metric_id      = "e1"
  alarm_description        = "CPU utilization has exceeded the anomaly detection threshold"
  insufficient_data_actions = []
  alarm_actions            = [aws_sns_topic.alarm_topic.arn]
  ok_actions              = [aws_sns_topic.alarm_topic.arn]

  metric_query {
    id          = "m1"
    return_data = true
    metric {
      metric_name = "CPUUtilization"
      namespace   = var.metric_namespace
      period     = var.cpu_anomaly_config.period
      stat       = var.cpu_anomaly_config.statistic
      dimensions = {
        Environment = var.environment
      }
    }
  }

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, ${var.cpu_anomaly_config.anomaly_band_width})"
    label       = "CPUUtilization (Expected)"
    return_data = true
  }

  tags = {
    Environment = var.environment
  }
}

# Anomaly Detection Alarm for Disk I/O
resource "aws_cloudwatch_metric_alarm" "disk_io_anomaly" {
  alarm_name                = "disk-io-anomaly-${var.environment}"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods       = var.disk_io_anomaly_config.evaluation_periods
  threshold_metric_id      = "e1"
  alarm_description        = "Disk I/O has exceeded the anomaly detection threshold"
  insufficient_data_actions = []
  alarm_actions            = [aws_sns_topic.alarm_topic.arn]
  ok_actions              = [aws_sns_topic.alarm_topic.arn]

  metric_query {
    id          = "m1"
    return_data = true
    metric {
      metric_name = "DiskIOUtilization"
      namespace   = var.metric_namespace
      period     = var.disk_io_anomaly_config.period
      stat       = var.disk_io_anomaly_config.statistic
      dimensions = {
        Environment = var.environment
      }
    }
  }

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, ${var.disk_io_anomaly_config.anomaly_band_width})"
    label       = "DiskIOUtilization (Expected)"
    return_data = true
  }

  tags = {
    Environment = var.environment
  }
}

# Memory Usage Alarm
resource "aws_cloudwatch_metric_alarm" "memory_usage" {
  alarm_name          = "memory-usage-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.memory_alarm_config.evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = var.metric_namespace
  period             = var.memory_alarm_config.period
  statistic          = var.memory_alarm_config.statistic
  threshold          = var.memory_alarm_config.threshold
  alarm_description  = "Memory utilization has exceeded the threshold"
  alarm_actions      = [aws_sns_topic.alarm_topic.arn]
  ok_actions         = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    Environment = var.environment
  }

  tags = {
    Environment = var.environment
  }
}