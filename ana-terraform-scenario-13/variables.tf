variable "aws_region" {
        description = "AWS region to deploy resources"
        type        = string
        default     = "ap-south-1"
    }

    variable "environment" {
        description = "Environment name (e.g., dev, prod)"
        type        = string
        default     = "prod"
    }

    variable "vpc_cidr" {
        description = "CIDR block for VPC"
        type        = string
        default     = "10.0.0.0/16"
    }

    variable "azs" {
        description = "Availability zones"
        type        = list(string)
        default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
    }

    variable "private_subnets" {
        description = "Private subnet CIDR blocks"
        type        = list(string)
        default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    }

    variable "alb_arns" {
        description = "List of ALB ARNs to associate with WAF"
        type        = list(string)
        default     = []
    }

    variable "api_gateway_arns" {
        description = "List of API Gateway stage ARNs to associate with WAF"
        type        = list(string)
        default     = []
    }

    variable "cloudfront_distribution_ids" {
        description = "List of CloudFront distribution IDs to associate with WAF"
        type        = list(string)
        default     = []
    }