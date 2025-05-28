resource "aws_vpc" "main" {
        cidr_block           = var.vpc_cidr
        enable_dns_hostnames = true
        enable_dns_support   = true

        tags = {
            Name = "${var.environment}-vpc"
        }
    }

    resource "aws_subnet" "private" {
        count             = length(var.private_subnets)
        vpc_id            = aws_vpc.main.id
        cidr_block        = var.private_subnets[count.index]
        availability_zone = var.azs[count.index]

        tags = {
            Name = "${var.environment}-private-${var.azs[count.index]}"
        }
    }

    # VPC Endpoints for AWS Services
    resource "aws_vpc_endpoint" "s3" {
        vpc_id       = aws_vpc.main.id
        service_name = "com.amazonaws.${var.aws_region}.s3"
        
        tags = {
            Name = "${var.environment}-s3-endpoint"
        }
    }

    # Security group for VPC endpoints
    resource "aws_security_group" "vpc_endpoints" {
        name_prefix = "vpc-endpoints-"
        vpc_id      = aws_vpc.main.id

        ingress {
            from_port   = 443
            to_port     = 443
            protocol    = "tcp"
            cidr_blocks = [var.vpc_cidr]
        }
    }

    # Interface endpoints for various AWS services
    resource "aws_vpc_endpoint" "interface_endpoints" {
        for_each = toset([
            "ssm",
            "ec2messages",
            "ec2",
            "kms",
            "logs",
            "monitoring",
            "sqs",
            "secretsmanager"
        ])

        vpc_id              = aws_vpc.main.id
        service_name        = "com.amazonaws.${var.aws_region}.${each.key}"
        vpc_endpoint_type   = "Interface"
        private_dns_enabled = true
        subnet_ids          = aws_subnet.private[*].id
        security_group_ids  = [aws_security_group.vpc_endpoints.id]

        tags = {
            Name = "${var.environment}-${each.key}-endpoint"
        }
    }