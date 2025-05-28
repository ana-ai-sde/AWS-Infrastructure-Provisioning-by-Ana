resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "${var.environment}-high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "cpu_usage_user"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "This metric monitors EC2 CPU utilization"
  treat_missing_data  = "breaching"

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-cpu-alarm"
      Environment = var.environment
      Type        = "CPU"
      Monitor     = "CloudWatch-Agent"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "memory_alarm" {
  alarm_name          = "${var.environment}-high-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors EC2 memory utilization"
  treat_missing_data  = "breaching"

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-memory-alarm"
      Environment = var.environment
      Type        = "Memory"
      Monitor     = "CloudWatch-Agent"
    }
  )
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-EC2-Monitoring-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["CWAgent", "cpu_usage_user", "InstanceId", var.instance_id, { label = "User CPU" }],
            ["CWAgent", "cpu_usage_system", "InstanceId", var.instance_id, { label = "System CPU" }],
            ["CWAgent", "cpu_usage_idle", "InstanceId", var.instance_id, { label = "Idle CPU" }]
          ]
          period = 300
          stat   = "Average"
          region = "ap-south-1"
          title  = "CPU Usage"
          view   = "timeSeries"
          stacked = false
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["CWAgent", "mem_used_percent", "InstanceId", var.instance_id, { label = "Memory Used %" }]
          ]
          period = 300
          stat   = "Average"
          region = "ap-south-1"
          title  = "Memory Usage"
          view   = "timeSeries"
          stacked = false
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      }
    ]
  })
}