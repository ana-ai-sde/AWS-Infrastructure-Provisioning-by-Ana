provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  environment       = var.environment
}

module "ec2" {
  source = "./modules/ec2"
  
  vpc_id            = module.vpc.vpc_id
  private_subnet_id = module.vpc.private_subnet_ids[0]
  environment       = var.environment
  depends_on        = [module.vpc]
}

# First create the onprem instance
module "onprem" {
  source = "./modules/onprem"
  
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnet_ids[0]
  environment       = var.environment
  vpc_cidr          = var.vpc_cidr
  depends_on        = [module.vpc]
}

# Then create the VPN connection
module "vpn" {
  source = "./modules/vpn"
  
  vpc_id                 = module.vpc.vpc_id
  vpc_cidr               = var.vpc_cidr
  onprem_public_ip       = module.onprem.instance_public_ip
  onprem_cidr           = var.onprem_cidr
  private_route_table_id = module.vpc.private_route_table_id
  depends_on            = [module.vpc, module.onprem]
}