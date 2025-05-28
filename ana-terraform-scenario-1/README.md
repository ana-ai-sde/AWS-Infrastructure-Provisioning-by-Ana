# Static Website Infrastructure with Terraform

This project contains Terraform configurations to deploy a static website on AWS using S3, CloudFront, ACM, and Route53.

## Initial Setup

1. First, create the backend infrastructure:
   ```bash 
   cd backend-setup
   terraform init
   terraform apply
   cd ..
   ```

2. Initialize the main project:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

[Rest of the README content remains the same...]
