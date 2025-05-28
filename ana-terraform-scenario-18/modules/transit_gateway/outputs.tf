output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "transit_gateway_attachment_id" {
  description = "ID of the Transit Gateway VPC attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.main.id
}

output "transit_gateway_peering_id" {
  description = "ID of the Transit Gateway peering attachment"
  value       = var.create_peering ? aws_ec2_transit_gateway_peering_attachment.peering[0].id : null
}