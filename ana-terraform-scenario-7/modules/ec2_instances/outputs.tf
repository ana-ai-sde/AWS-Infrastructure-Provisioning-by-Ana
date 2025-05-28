output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.instance_asg.name
}

output "instance_security_group_id" {
  description = "ID of the instance security group"
  value       = aws_security_group.instance_sg.id
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.instance_template.id
}