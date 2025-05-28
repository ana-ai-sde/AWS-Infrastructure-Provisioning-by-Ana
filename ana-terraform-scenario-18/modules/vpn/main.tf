resource "aws_customer_gateway" "main" {
  bgp_asn    = var.customer_gateway_asn
  ip_address = var.customer_gateway_ip
  type       = "ipsec.1"

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-cgw"
    }
  )
}

resource "aws_vpn_connection" "main" {
  customer_gateway_id = aws_customer_gateway.main.id
  transit_gateway_id = var.transit_gateway_id
  type               = "ipsec.1"
  
  static_routes_only = false

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-vpn"
    }
  )

  tunnel1_inside_cidr = var.tunnel1_inside_cidr
  tunnel2_inside_cidr = var.tunnel2_inside_cidr
}