terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "core_infrastructure" {
  source = "./modules/core_infrastructure"
  
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  aws_region      = var.aws_region
  cluster_name    = var.cluster_name
}

module "observability_stack" {
  source = "./modules/observability_stack"
  
  environment      = var.environment
  vpc_id          = module.core_infrastructure.vpc_id
  private_subnets = module.core_infrastructure.private_subnets
  cluster_id      = module.core_infrastructure.cluster_id
  aws_region      = var.aws_region
}