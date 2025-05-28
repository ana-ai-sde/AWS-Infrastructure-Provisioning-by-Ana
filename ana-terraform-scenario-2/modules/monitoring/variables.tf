variable "instance_id" {
  description = "ID of the EC2 instance to monitor"
  type        = string
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for alarm"
  type        = number
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to CloudWatch resources"
  type        = map(string)
  default     = {}
}