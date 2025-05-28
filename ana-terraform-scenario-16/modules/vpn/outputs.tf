output "vpn_connection_id" {
  description = "VPN Connection ID"
  value       = aws_vpn_connection.main.id
}

output "tunnel1_address" {
  description = "First VPN tunnel endpoint"
  value       = aws_vpn_connection.main.tunnel1_address
}

output "tunnel2_address" {
  description = "Second VPN tunnel endpoint"
  value       = aws_vpn_connection.main.tunnel2_address
}

output "tunnel1_preshared_key" {
  description = "First VPN tunnel preshared key"
  value       = aws_vpn_connection.main.tunnel1_preshared_key
  sensitive   = true
}

output "tunnel2_preshared_key" {
  description = "Second VPN tunnel preshared key"
  value       = aws_vpn_connection.main.tunnel2_preshared_key
  sensitive   = true
}