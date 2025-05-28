output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.monitored_instance.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.monitored_instance.public_ip
}