# Primary Region CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "vpn_tunnel1_status_primary" {
  provider            = aws.primary
  alarm_name          = "vpn-tunnel1-status-primary"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors primary region VPN tunnel 1 status"

  dimensions = {
    VpnId = module.vpn_primary_1.vpn_connection_id
  }

  tags = {
    Environment = var.environment
    Region      = "ap-south-1"
  }
}

resource "aws_cloudwatch_metric_alarm" "vpn_tunnel2_status_primary" {
  provider            = aws.primary
  alarm_name          = "vpn-tunnel2-status-primary"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors primary region VPN tunnel 2 status"

  dimensions = {
    VpnId = module.vpn_primary_2.vpn_connection_id
  }

  tags = {
    Environment = var.environment
    Region      = "ap-south-1"
  }
}

# Secondary Region CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "vpn_tunnel1_status_secondary" {
  provider            = aws.secondary
  alarm_name          = "vpn-tunnel1-status-secondary"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors secondary region VPN tunnel 1 status"

  dimensions = {
    VpnId = module.vpn_secondary_1.vpn_connection_id
  }

  tags = {
    Environment = var.environment
    Region      = "us-east-1"
  }
}

resource "aws_cloudwatch_metric_alarm" "vpn_tunnel2_status_secondary" {
  provider            = aws.secondary
  alarm_name          = "vpn-tunnel2-status-secondary"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors secondary region VPN tunnel 2 status"

  dimensions = {
    VpnId = module.vpn_secondary_2.vpn_connection_id
  }

  tags = {
    Environment = var.environment
    Region      = "us-east-1"
  }
}