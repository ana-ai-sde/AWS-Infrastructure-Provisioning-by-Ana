variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., prod, dev, staging)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "alb_ingress_rules" {
  description = "List of ingress rules for ALB"
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    },
    {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS"
    }
  ]
}

variable "app_port" {
  description = "Port on which the application runs"
  type        = number
  default     = 80
}

variable "db_port" {
  description = "Port for database connections"
  type        = number
  default     = 5432
}

variable "ssh_allowed_cidrs" {
  description = "List of CIDR blocks allowed to SSH into EC2 instances"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for security group resources"
  type        = map(string)
  default     = {}
}