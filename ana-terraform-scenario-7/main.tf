terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"

  environment          = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnet_cidrs))
}

module "cloudwatch_agent" {
  source = "./modules/cloudwatch_agent"

  environment = var.environment
}

module "cloudwatch_logs" {
  source = "./modules/cloudwatch_logs"

  environment    = var.environment
  retention_days = var.retention_days
}

module "cloudwatch_dashboard" {
  source = "./modules/cloudwatch_dashboard"

  environment      = var.environment
  aws_region      = var.aws_region
  metric_namespace = var.metric_namespace
  log_group_name   = module.cloudwatch_logs.application_log_group_name
}

module "cloudwatch_alarms" {
  source = "./modules/cloudwatch_alarms"

  environment           = var.environment
  metric_namespace      = var.metric_namespace
  alarm_email_endpoints = var.alarm_email_endpoints
  cpu_anomaly_config    = var.cpu_anomaly_config
  disk_io_anomaly_config = var.disk_io_anomaly_config
  memory_alarm_config   = var.memory_alarm_config
}

module "ec2_instances" {
  source = "./modules/ec2_instances"

  environment                   = var.environment
  aws_region                   = var.aws_region
  instance_type                = var.instance_type
  instance_count               = var.instance_count
  subnet_ids                   = module.vpc.private_subnet_ids
  vpc_id                       = module.vpc.vpc_id
  allowed_ssh_cidr_blocks      = [module.vpc.vpc_cidr]
  cloudwatch_agent_profile_name = module.cloudwatch_agent.agent_profile_name
  cloudwatch_agent_config_param = module.cloudwatch_agent.agent_config_parameter
}