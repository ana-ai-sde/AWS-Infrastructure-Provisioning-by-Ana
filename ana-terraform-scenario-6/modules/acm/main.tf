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

# Request certificate
resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-certificate"
    }
  )
}

# CloudWatch alarm for certificate expiry
resource "aws_cloudwatch_metric_alarm" "certificate_expiry" {
  count = var.monitoring.enabled ? 1 : 0

  alarm_name          = "${local.name_prefix}-certificate-expiry"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.monitoring.evaluation_periods
  metric_name         = "DaysToExpiry"
  namespace           = "AWS/CertificateManager"
  period              = var.monitoring.period
  statistic           = "Minimum"
  threshold           = var.monitoring.expiry_days
  alarm_description   = "Certificate expiry monitoring for ${var.domain_name}"
  alarm_actions       = var.monitoring.alarm_actions

  dimensions = {
    CertificateArn = aws_acm_certificate.main.arn
  }

  tags = local.default_tags
}