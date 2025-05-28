provider "aws" {
  region = var.aws_region
}

module "synthetic_monitoring" {
  source = "./modules/synthetic_monitoring"
  
  monitoring_name = "url-monitor"
  url_to_monitor = var.url_to_monitor
  schedule_expression = "rate(5 minutes)"
}

module "notification" {
  source = "./modules/notification"
  
  sns_topic_name = "url-monitoring-alerts"
  email_endpoints = var.email_endpoints
}

module "alarm" {
  source = "./modules/alarm"
  
  alarm_name = "url-monitoring-alarm"
  canary_name = module.synthetic_monitoring.canary_name
  sns_topic_arn = module.notification.sns_topic_arn
  evaluation_periods = 2
  threshold = 90
}