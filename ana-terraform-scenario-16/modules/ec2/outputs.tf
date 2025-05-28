output "instance_private_ip" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.main.private_ip
}