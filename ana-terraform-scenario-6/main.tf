terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # You can uncomment and configure this block for remote state
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "terraform.tfstate"
  #   region         = "us-west-2"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  tags         = var.tags
}

# Subnets Module
module "subnets" {
  source = "./modules/subnets"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  internet_gateway_id = module.vpc.internet_gateway_id
  availability_zones = var.availability_zones

  public_subnet_cidrs  = [for i, az in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnet_cidrs = [for i, az in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, i + length(var.availability_zones))]

  tags = var.tags
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security_groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
  db_port      = var.db_config.port

  tags = var.tags
}

# ACM Module
module "acm" {
  source = "./modules/acm"

  project_name = var.project_name
  environment  = var.environment
  domain_name  = var.domain_name

  monitoring = {
    enabled            = true
    evaluation_periods = 1
    period            = 86400
    expiry_days       = 30
    alarm_actions     = []
  }

  tags = var.tags
}

# ALB Module
module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.subnets.public_subnet_ids
  security_group_id = module.security_groups.alb_security_group_id

  ssl_configuration = {
    certificate_arn = module.acm.certificate_arn
    ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  }

  alb_settings = {
    internal                   = false
    enable_deletion_protection = true
    enable_http2              = true
    idle_timeout              = 60
  }

  tags = var.tags
}

# ASG Module
module "asg" {
  source = "./modules/asg"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.subnets.private_subnet_ids

  target_group_arns  = [module.alb.target_group_arn]
  security_group_ids = [module.security_groups.ec2_security_group_id]

  instance_config = {
    instance_type = var.instance_type
    ami_id        = data.aws_ami.amazon_linux_2.id
    key_name      = aws_key_pair.main.key_name
    user_data     = base64encode("#!/bin/bash\necho 'Hello, World!'")
    root_volume = {
      size                  = 30
      type                  = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
    ebs_volumes = []
  }

  asg_config = var.asg_config

  tags = var.tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.subnets.private_subnet_ids

  security_group_ids = [module.security_groups.rds_security_group_id]
  db_config         = var.db_config

  multi_az_config = {
    multi_az                    = true
    availability_zone          = null
    ca_cert_identifier        = "rds-ca-2019"
    auto_minor_version_upgrade = true
  }

  tags = var.tags
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment

  ec2_role_config = {
    enable_ssm        = true
    enable_cloudwatch = true
    custom_policies   = {}
  }

  backup_role_config = {
    enabled           = true
    backup_resources  = ["*"]
    restore_resources = ["*"]
  }

  tags = var.tags
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  project_name = var.project_name
  environment  = var.environment

  alarm_notification_config = {
    enabled = true
    endpoints = {
      email = {
        type     = "email"
        endpoint = var.alarm_email
      }
    }
    default_actions = []
  }

  ec2_monitoring = {
    enabled = true
    metrics = {
      cpu_utilization = {
        metric_name         = "CPUUtilization"
        namespace          = "AWS/EC2"
        statistic          = "Average"
        comparison_operator = "GreaterThanThreshold"
        threshold          = 80
        period             = 300
        evaluation_periods = 2
        datapoints_to_alarm = 2
        treat_missing_data = "missing"
        actions            = []
      }
    }
    dimensions = {
      AutoScalingGroupName = module.asg.asg_name
    }
  }

  rds_monitoring = {
    enabled = true
    metrics = {
      cpu_utilization = {
        metric_name         = "CPUUtilization"
        namespace          = "AWS/RDS"
        statistic          = "Average"
        comparison_operator = "GreaterThanThreshold"
        threshold          = 80
        period             = 300
        evaluation_periods = 2
        datapoints_to_alarm = 2
        treat_missing_data = "missing"
        actions            = []
      }
    }
    dimensions = {
      DBInstanceIdentifier = module.rds.db_instance_id
    }
  }

  tags = var.tags
}

# Data Sources
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Key Pair
resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-${var.environment}-key"
  public_key = file("${path.module}/files/ssh_key.pub")

  tags = var.tags
}