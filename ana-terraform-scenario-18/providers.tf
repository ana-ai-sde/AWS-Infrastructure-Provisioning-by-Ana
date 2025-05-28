terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

# Primary region provider (Mumbai)
provider "aws" {
  region = var.primary_region
  alias  = "primary"
}

# Secondary region provider (Hyderabad)
provider "aws" {
  region = var.secondary_region
  alias  = "secondary"
}