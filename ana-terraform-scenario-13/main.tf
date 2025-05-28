terraform {
    required_version = ">= 1.0.0"
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 4.0"
        }
    }
    }

    provider "aws" {
    region = var.aws_region

    default_tags {
        tags = {
        Environment = var.environment
        Project     = "zero-trust-infrastructure"
        Terraform   = "true"
        }
    }
    }

    # Additional provider for CloudFront WAF (Global)
    provider "aws" {
        alias  = "global"
        region = "us-east-1"  # CloudFront requires WAF to be created in us-east-1
    }

    # VPC Module
    module "vpc" {
        source = "./modules/vpc"

        vpc_cidr        = var.vpc_cidr
        environment     = var.environment
        aws_region      = var.aws_region
        azs             = var.azs
        private_subnets = var.private_subnets
    }

    # Security Module
    module "security" {
        source = "./modules/security"

        environment = var.environment
        aws_region  = var.aws_region
        vpc_id      = module.vpc.vpc_id
        
        # Example of associating WAF with resources
        alb_arns             = var.alb_arns
        api_gateway_arns     = var.api_gateway_arns
        cloudfront_distributions = var.cloudfront_distribution_ids
    }

    # IAM Module
    module "iam" {
        source = "./modules/iam"

        environment = var.environment
        aws_region  = var.aws_region
    }