variable "environment" {
        description = "Environment name"
        type        = string
    }

    variable "aws_region" {
        description = "AWS region"
        type        = string
    }

    variable "vpc_id" {
        description = "VPC ID for flow logs"
        type        = string
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

    variable "cloudfront_distributions" {
        description = "List of CloudFront distribution IDs to associate with WAF"
        type        = list(string)
        default     = []
    }

    variable "waf_log_retention" {
        description = "Number of days to retain WAF logs"
        type        = number
        default     = 90
    }