provider "aws" {
  region = var.aws_region
}

# Create EC2 Instance
module "ec2" {
  source = "./modules/ec2"
  aws_region = var.aws_region
}

# SNS Topic for notifications
module "notification" {
  source = "./modules/notification"
  sns_topic_name = "sre-alerts"
  email_addresses = var.notification_emails
}

# Monitoring and Alarms
module "monitoring" {
  source = "./modules/monitoring"
  instance_id = module.ec2.instance_id
  sns_topic_arn = module.notification.sns_topic_arn
  alarm_threshold = var.cpu_threshold
}

# Remediation Lambda
module "remediation" {
  source = "./modules/remediation"
  function_name = "ec2-cpu-remediation"
  sns_topic_arn = module.notification.sns_topic_arn
  instance_id = module.ec2.instance_id
}