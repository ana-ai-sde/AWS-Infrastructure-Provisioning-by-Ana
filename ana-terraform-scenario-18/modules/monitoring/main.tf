resource "aws_cloudwatch_metric_alarm" "vpn_tunnel_status" {
  alarm_name          = "${var.name}-vpn-tunnel-status"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors VPN tunnel status"

  dimensions = {
    VpnId = var.vpn_connection_id
  }

  tags = var.tags
}