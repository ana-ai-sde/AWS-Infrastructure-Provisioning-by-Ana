terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# Example SNS Topic
module "notification_topic" {
  source = "./modules/sns"
  name   = "example-notifications"
  
  tags = {
    Environment = var.environment
    Purpose     = "Notifications"
  }
}