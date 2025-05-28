# AWS Infrastructure with Terraform

This repository contains Terraform configurations to deploy a modular AWS infrastructure with the following components:

- VPC with configurable CIDR block
- Two public subnets across different availability zones
- Two private subnets across different availability zones
- Internet Gateway for public internet access
- NAT Gateway for outbound internet access from private subnets
- Appropriate route tables for both public and private subnets

## Architecture

The infrastructure is organized into modular components:

- `vpc` module: Manages VPC, subnets, Internet Gateway, and public route tables
- `nat` module: Manages NAT Gateway and private route tables

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- GitHub repository with AWS credentials configured as secrets

## Configuration

The infrastructure can be customized through variables in `variables.tf`:

- `aws_region`: AWS region to deploy resources
- `environment`: Environment name (e.g., dev, prod)
- `project`: Project name
- `vpc_cidr`: CIDR block for the VPC
- `public_subnet_cidrs`: CIDR blocks for public subnets
- `private_subnet_cidrs`: CIDR blocks for private subnets

## Usage

1. Clone the repository
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review the plan:
   ```bash
   terraform plan
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```

## CI/CD

The repository includes a GitHub Actions workflow (`ci.yaml`) that automatically:

1. Validates Terraform code
2. Plans changes on pull requests
3. Applies changes when merging to main

Required GitHub Secrets:
- `AWS_ACCESS_KEY`: AWS access key ID
- `AWS_SECRET_ACCESS_KEY`: AWS secret access key

## Outputs

- `vpc_id`: ID of the created VPC
- `public_subnet_ids`: List of public subnet IDs
- `private_subnet_ids`: List of private subnet IDs
- `nat_gateway_id`: ID of the NAT Gateway