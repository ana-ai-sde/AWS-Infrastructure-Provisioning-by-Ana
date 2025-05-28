variable "vpc_cidr" {
        description = "CIDR block for VPC"
        type        = string
    }

    variable "environment" {
        description = "Environment name"
        type        = string
    }

    variable "aws_region" {
        description = "AWS region"
        type        = string
    }

    variable "azs" {
        description = "Availability zones"
        type        = list(string)
    }

    variable "private_subnets" {
        description = "Private subnet CIDR blocks"
        type        = list(string)
    }