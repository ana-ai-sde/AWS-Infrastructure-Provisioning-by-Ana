output "vpn_connection_id" {
  description = "ID of the VPN connection"
  value       = aws_vpn_connection.main.id
}

output "customer_gateway_id" {
  description = "ID of the Customer Gateway"
  value       = aws_customer_gateway.main.id
}

output "vpn_connection_tunnel1_address" {
  description = "Public IP address of the first VPN tunnel"
  value       = aws_vpn_connection.main.tunnel1_address
}

output "vpn_connection_tunnel2_address" {
  description = "Public IP address of the second VPN tunnel"
  value       = aws_vpn_connection.main.tunnel2_address
}

output "vpn_connection_tunnel1_preshared_key" {
  description = "Preshared key of the first VPN tunnel"
  value       = aws_vpn_connection.main.tunnel1_preshared_key
  sensitive   = true
}

output "vpn_connection_tunnel2_preshared_key" {
  description = "Preshared key of the second VPN tunnel"
  value       = aws_vpn_connection.main.tunnel2_preshared_key
  sensitive   = true
}