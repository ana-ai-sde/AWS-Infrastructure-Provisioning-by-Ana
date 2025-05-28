locals {
  security_group_rules = {
    ingress = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.ssh_cidr]
        description = "SSH access"
      }
    ]
    egress = var.security_group_rules.egress
  }

  common_tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

module "vpc" {
  source = "./modules/vpc"

  environment        = var.environment
  region            = var.aws_region
  vpc_cidr          = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  tags              = local.common_tags
}

module "iam" {
  source = "./modules/iam"
}

module "ssm" {
  source = "./modules/ssm"

  environment = var.environment
  tags        = local.common_tags
}

module "security_group" {
  source = "./modules/security_group"

  name_prefix    = "ec2-monitoring"
  description    = "Security group for EC2 monitoring instance"
  vpc_id         = module.vpc.vpc_id
  ingress_rules  = local.security_group_rules.ingress
  egress_rules   = local.security_group_rules.egress
  tags           = local.common_tags
}

module "ec2" {
  source = "./modules/ec2"

  instance_type      = var.instance_type
  environment        = var.environment
  instance_profile   = module.iam.instance_profile_name
  security_group_id  = module.security_group.security_group_id
  subnet_id          = module.vpc.public_subnet_id
  key_name           = var.key_name
  ssm_parameter_name = module.ssm.cloudwatch_config_parameter_name
  tags               = local.common_tags
}

module "monitoring" {
  source = "./modules/monitoring"

  instance_id    = module.ec2.instance_id
  cpu_threshold  = var.cpu_threshold
  environment    = var.environment
  tags           = local.common_tags
}