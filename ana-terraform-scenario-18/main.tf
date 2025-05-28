# Primary Region (Mumbai) Resources
module "vpc_primary" {
  source = "./modules/vpc"

  name               = "primary-mumbai"
  vpc_cidr          = var.vpc_cidr_primary
  availability_zones = ["ap-south-1a", "ap-south-1b"]
  
  providers = {
    aws = aws.primary
  }

  tags = {
    Environment = var.environment
    Region      = "ap-south-1"
  }
}

module "transit_gateway_primary" {
  source = "./modules/transit_gateway"

  name            = "primary-mumbai"
  description     = "Primary Transit Gateway - Mumbai"
  amazon_side_asn = var.vpn_bgp_asn
  vpc_id          = module.vpc_primary.vpc_id
  subnet_ids      = module.vpc_primary.public_subnet_ids
  
  # Enable peering in primary region
  create_peering  = true
  peer_tgw_id     = module.transit_gateway_secondary.transit_gateway_id
  peer_region     = var.secondary_region
  peer_account_id = data.aws_caller_identity.current.account_id

  providers = {
    aws = aws.primary
  }

  tags = {
    Environment = var.environment
    Region      = "ap-south-1"
  }
}

# Secondary Region (N. Virginia) Resources
module "vpc_secondary" {
  source = "./modules/vpc"

  name               = "secondary-virginia"
  vpc_cidr          = var.vpc_cidr_secondary
  availability_zones = ["us-east-1a", "us-east-1b"]
  
  providers = {
    aws = aws.secondary
  }

  tags = {
    Environment = var.environment
    Region      = "us-east-1"
  }
}

module "transit_gateway_secondary" {
  source = "./modules/transit_gateway"

  name            = "secondary-virginia"
  description     = "Secondary Transit Gateway - N. Virginia"
  amazon_side_asn = var.vpn_bgp_asn_secondary
  vpc_id          = module.vpc_secondary.vpc_id
  subnet_ids      = module.vpc_secondary.public_subnet_ids

  # Disable peering in secondary region
  create_peering = false

  providers = {
    aws = aws.secondary
  }

  tags = {
    Environment = var.environment
    Region      = "us-east-1"
  }
}

# Primary Region StrongSwan Instances
module "strongswan_primary_1" {
  source = "./modules/strongswan"

  name              = "primary-mumbai-1"
  instance_type     = var.strongswan_instance_type
  subnet_id         = module.vpc_primary.public_subnet_ids[0]
  vpc_id            = module.vpc_primary.vpc_id
  user_data_template = "${path.module}/templates/strongswan_config.tpl"
  
  providers = {
    aws = aws.primary
  }

  tags = {
    Environment = var.environment
    Region      = "ap-south-1"
  }
}

module "strongswan_primary_2" {
  source = "./modules/strongswan"

  name              = "primary-mumbai-2"
  instance_type     = var.strongswan_instance_type
  subnet_id         = module.vpc_primary.public_subnet_ids[1]
  vpc_id            = module.vpc_primary.vpc_id
  user_data_template = "${path.module}/templates/strongswan_config.tpl"
  
  providers = {
    aws = aws.primary
  }

  tags = {
    Environment = var.environment
    Region      = "ap-south-1"
  }
}

# Primary Region VPN Connections
module "vpn_primary_1" {
  source = "./modules/vpn"

  name                = "primary-mumbai-1"
  customer_gateway_asn = var.customer_gateway_asn_primary
  customer_gateway_ip  = module.strongswan_primary_1.public_ip
  transit_gateway_id   = module.transit_gateway_primary.transit_gateway_id

  providers = {
    aws = aws.primary
  }

  tags = {
    Environment = var.environment
    Region      = "ap-south-1"
  }
}

module "vpn_primary_2" {
  source = "./modules/vpn"

  name                = "primary-mumbai-2"
  customer_gateway_asn = var.customer_gateway_asn_primary
  customer_gateway_ip  = module.strongswan_primary_2.public_ip
  transit_gateway_id   = module.transit_gateway_primary.transit_gateway_id

  providers = {
    aws = aws.primary
  }

  tags = {
    Environment = var.environment
    Region      = "ap-south-1"
  }
}

# Secondary Region StrongSwan Instances
module "strongswan_secondary_1" {
  source = "./modules/strongswan"

  name              = "secondary-virginia-1"
  instance_type     = var.strongswan_instance_type
  subnet_id         = module.vpc_secondary.public_subnet_ids[0]
  vpc_id            = module.vpc_secondary.vpc_id
  user_data_template = "${path.module}/templates/strongswan_config.tpl"
  
  providers = {
    aws = aws.secondary
  }

  tags = {
    Environment = var.environment
    Region      = "us-east-1"
  }
}

module "strongswan_secondary_2" {
  source = "./modules/strongswan"

  name              = "secondary-virginia-2"
  instance_type     = var.strongswan_instance_type
  subnet_id         = module.vpc_secondary.public_subnet_ids[1]
  vpc_id            = module.vpc_secondary.vpc_id
  user_data_template = "${path.module}/templates/strongswan_config.tpl"
  
  providers = {
    aws = aws.secondary
  }

  tags = {
    Environment = var.environment
    Region      = "us-east-1"
  }
}

# Secondary Region VPN Connections
module "vpn_secondary_1" {
  source = "./modules/vpn"

  name                = "secondary-virginia-1"
  customer_gateway_asn = var.customer_gateway_asn_secondary
  customer_gateway_ip  = module.strongswan_secondary_1.public_ip
  transit_gateway_id   = module.transit_gateway_secondary.transit_gateway_id

  providers = {
    aws = aws.secondary
  }

  tags = {
    Environment = var.environment
    Region      = "us-east-1"
  }
}

module "vpn_secondary_2" {
  source = "./modules/vpn"

  name                = "secondary-virginia-2"
  customer_gateway_asn = var.customer_gateway_asn_secondary
  customer_gateway_ip  = module.strongswan_secondary_2.public_ip
  transit_gateway_id   = module.transit_gateway_secondary.transit_gateway_id

  providers = {
    aws = aws.secondary
  }

  tags = {
    Environment = var.environment
    Region      = "us-east-1"
  }
}

# CloudWatch Monitoring
module "monitoring_primary" {
  source = "./modules/monitoring"

  name              = "primary-mumbai"
  vpn_connection_id = module.vpn_primary_1.vpn_connection_id

  providers = {
    aws = aws.primary
  }

  tags = {
    Environment = var.environment
    Region      = "ap-south-1"
  }
}

module "monitoring_secondary" {
  source = "./modules/monitoring"

  name              = "secondary-virginia"
  vpn_connection_id = module.vpn_secondary_1.vpn_connection_id

  providers = {
    aws = aws.secondary
  }

  tags = {
    Environment = var.environment
    Region      = "us-east-1"
  }
}

# Data source for current account ID
data "aws_caller_identity" "current" {}