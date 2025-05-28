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
  region = "ap-south-1"
}

module "vpc" {
  source = "./modules/vpc"

  cidr_block  = var.vpc_cidr
  environment = var.environment
}

module "subnets" {
  source = "./modules/subnets"
  depends_on = [module.vpc]

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  igw_id      = module.vpc.igw_id
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "nat" {
  source = "./modules/nat"
  depends_on = [module.subnets]

  vpc_id                = module.vpc.vpc_id
  environment           = var.environment
  public_subnet_id      = module.subnets.public_subnet_ids[0]
  private_route_table_id = module.subnets.private_route_table_id
}