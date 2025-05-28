output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "aws_instance_private_ip" {
  description = "Private IP of AWS EC2 instance"
  value       = module.ec2.instance_private_ip
}

output "onprem_instance_public_ip" {
  description = "Public IP of on-premises EC2 instance"
  value       = module.onprem.instance_public_ip
}

output "vpn_tunnel1_address" {
  description = "First VPN tunnel endpoint"
  value       = module.vpn.tunnel1_address
}

output "vpn_tunnel2_address" {
  description = "Second VPN tunnel endpoint"
  value       = module.vpn.tunnel2_address
}

output "vpn_connection_id" {
  description = "VPN Connection ID"
  value       = module.vpn.vpn_connection_id
}