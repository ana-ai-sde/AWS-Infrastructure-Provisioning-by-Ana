# Primary Region (Mumbai) Outputs
output "primary_vpc_id" {
  description = "ID of the primary VPC in Mumbai"
  value       = module.vpc_primary.vpc_id
}

output "primary_transit_gateway_id" {
  description = "ID of the primary Transit Gateway in Mumbai"
  value       = module.transit_gateway_primary.transit_gateway_id
}

output "primary_vpn_connection_1_id" {
  description = "ID of the first VPN connection in Mumbai"
  value       = module.vpn_primary_1.vpn_connection_id
}

output "primary_vpn_connection_2_id" {
  description = "ID of the second VPN connection in Mumbai"
  value       = module.vpn_primary_2.vpn_connection_id
}

output "primary_strongswan_1_public_ip" {
  description = "Public IP of the first StrongSwan instance in Mumbai"
  value       = module.strongswan_primary_1.public_ip
}

output "primary_strongswan_2_public_ip" {
  description = "Public IP of the second StrongSwan instance in Mumbai"
  value       = module.strongswan_primary_2.public_ip
}

# Secondary Region (Hyderabad) Outputs
output "secondary_vpc_id" {
  description = "ID of the secondary VPC in Hyderabad"
  value       = module.vpc_secondary.vpc_id
}

output "secondary_transit_gateway_id" {
  description = "ID of the secondary Transit Gateway in Hyderabad"
  value       = module.transit_gateway_secondary.transit_gateway_id
}

output "secondary_vpn_connection_1_id" {
  description = "ID of the first VPN connection in Hyderabad"
  value       = module.vpn_secondary_1.vpn_connection_id
}

output "secondary_vpn_connection_2_id" {
  description = "ID of the second VPN connection in Hyderabad"
  value       = module.vpn_secondary_2.vpn_connection_id
}

output "secondary_strongswan_1_public_ip" {
  description = "Public IP of the first StrongSwan instance in Hyderabad"
  value       = module.strongswan_secondary_1.public_ip
}

output "secondary_strongswan_2_public_ip" {
  description = "Public IP of the second StrongSwan instance in Hyderabad"
  value       = module.strongswan_secondary_2.public_ip
}

# Transit Gateway Peering
output "tgw_peering_attachment_id" {
  description = "ID of the Transit Gateway peering attachment"
  value       = module.transit_gateway_primary.transit_gateway_peering_id
}