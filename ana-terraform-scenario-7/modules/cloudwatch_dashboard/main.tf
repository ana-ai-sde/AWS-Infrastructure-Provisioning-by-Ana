resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "system-metrics-${var.environment}"

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
            ["${var.metric_namespace}", "CPUUtilization", "Environment", var.environment],
            ["${var.metric_namespace}", "MemoryUtilization", "Environment", var.environment],
            ["${var.metric_namespace}", "DiskIOUtilization", "Environment", var.environment]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "System Metrics"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          query = "SOURCE '${var.log_group_name}' | fields @timestamp, @message\n| sort @timestamp desc\n| limit 20"
          region = var.aws_region
          title  = "Recent Application Logs"
        }
      }
    ]
  })
}