output "alb_id" {
  description = "The ID of the ALB"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "target_group_id" {
  description = "The ID of the Target Group"
  value       = aws_lb_target_group.main.id
}

output "target_group_arn" {
  description = "The ARN of the Target Group"
  value       = aws_lb_target_group.main.arn
}

output "listener_arn" {
  description = "The ARN of the listener"
  value       = aws_lb_listener.main.arn
}