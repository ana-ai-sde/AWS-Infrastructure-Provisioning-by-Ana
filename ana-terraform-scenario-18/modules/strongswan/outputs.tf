output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.strongswan.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.strongswan.public_ip
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.strongswan.private_ip
}