variable "instance_id" {
  description = "ID of the EC2 instance to monitor"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  type        = string
}

variable "alarm_threshold" {
  description = "Threshold for CPU alarm"
  type        = number
}