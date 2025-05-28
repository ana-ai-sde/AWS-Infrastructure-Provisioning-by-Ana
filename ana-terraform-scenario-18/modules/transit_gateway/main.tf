resource "aws_ec2_transit_gateway" "main" {
  description                     = var.description
  amazon_side_asn                = var.amazon_side_asn
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-tgw"
    }
  )
}

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-tgw-attachment"
    }
  )
}

# Transit Gateway Peering - Only create in primary region
resource "aws_ec2_transit_gateway_peering_attachment" "peering" {
  count = var.create_peering ? 1 : 0

  peer_account_id      = var.peer_account_id
  peer_region          = var.peer_region
  peer_transit_gateway_id = var.peer_tgw_id
  transit_gateway_id   = aws_ec2_transit_gateway.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-tgw-peering"
    }
  )
}