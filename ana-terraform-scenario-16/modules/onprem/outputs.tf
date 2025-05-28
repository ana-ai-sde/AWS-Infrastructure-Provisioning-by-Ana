output "instance_public_ip" {
  description = "Public IP of on-premises EC2 instance"
  value       = aws_instance.onprem.public_ip
}