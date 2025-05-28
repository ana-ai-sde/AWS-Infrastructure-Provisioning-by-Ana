resource "aws_sagemaker_endpoint_configuration" "monitoring" {
  name = "${var.project_name}-monitoring-config"

  production_variants {
    variant_name           = "default"
    model_name            = var.endpoint_name
    initial_instance_count = 1
    instance_type         = "ml.t2.medium"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket" "monitoring" {
  bucket = "${var.project_name}-monitoring-${var.environment}"
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role" "monitoring_role" {
  name = "${var.project_name}-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "monitoring_policy" {
  name = "${var.project_name}-monitoring-policy"
  role = aws_iam_role.monitoring_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "sagemaker:*",
          "logs:*",
          "cloudwatch:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_cloudwatch_dashboard" "ml_dashboard" {
  dashboard_name = "${var.project_name}-monitoring"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/SageMaker", "ModelLatency", "EndpointName", var.endpoint_name],
            ["AWS/SageMaker", "Invocations", "EndpointName", var.endpoint_name],
            ["AWS/SageMaker", "CPUUtilization", "EndpointName", var.endpoint_name],
            ["AWS/SageMaker", "MemoryUtilization", "EndpointName", var.endpoint_name]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "Model Performance Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/SageMaker", "InvocationsPerInstance", "EndpointName", var.endpoint_name],
            ["AWS/SageMaker", "ModelLatency", "EndpointName", var.endpoint_name, "VariantName", "AllTraffic"]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "Model Traffic Metrics"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "model_latency" {
  alarm_name          = "${var.project_name}-model-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ModelLatency"
  namespace           = "AWS/SageMaker"
  period             = "300"
  statistic          = "Average"
  threshold          = "100"
  alarm_description  = "Model latency is too high"
  alarm_actions      = [var.alert_sns_topic_arn]
  
  dimensions = {
    EndpointName = var.endpoint_name
  }
}

resource "aws_cloudwatch_metric_alarm" "invocation_errors" {
  alarm_name          = "${var.project_name}-invocation-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Invocation4XXErrors"
  namespace           = "AWS/SageMaker"
  period             = "300"
  statistic          = "Sum"
  threshold          = "10"
  alarm_description  = "High number of invocation errors detected"
  alarm_actions      = [var.alert_sns_topic_arn]
  
  dimensions = {
    EndpointName = var.endpoint_name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "${var.project_name}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/SageMaker"
  period             = "300"
  statistic          = "Average"
  threshold          = "85"
  alarm_description  = "High CPU utilization detected"
  alarm_actions      = [var.alert_sns_topic_arn]
  
  dimensions = {
    EndpointName = var.endpoint_name
  }
}

data "aws_region" "current" {}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            



















































































































































































































































































































































