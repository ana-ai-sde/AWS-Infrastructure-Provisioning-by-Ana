terraform {
  backend "s3" {
    bucket         = "static-website-dev-terraform-state"
    key            = "static-website/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "static-website-dev-terraform-state-lock"
  }
}