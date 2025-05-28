resource "aws_vpn_gateway" "main" {
  vpc_id = var.vpc_id

  tags = {
    Name = "main-vpn-gateway"
  }
}

resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = var.onprem_public_ip
  type       = "ipsec.1"

  tags = {
    Name = "main-customer-gateway"
  }
}

resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.main.id
  type               = "ipsec.1"
  static_routes_only = true

  tags = {
    Name = "main-vpn-connection"
  }
}

resource "aws_vpn_connection_route" "main" {
  destination_cidr_block = var.onprem_cidr
  vpn_connection_id      = aws_vpn_connection.main.id
}

resource "aws_route" "vpn_route" {
  route_table_id         = var.private_route_table_id
  destination_cidr_block = var.onprem_cidr
  gateway_id            = aws_vpn_gateway.main.id
}

# Generate strongSwan configuration
resource "local_file" "strongswan_config" {
  filename = "strongswan_config.sh"
  content  = <<-EOF
    #!/bin/bash
    
    # Configure strongSwan
    cat > /etc/strongswan/ipsec.conf <<'EOL'
    config setup
        charondebug="all"
        uniqueids=yes

    conn %default
        ikelifetime=60m
        keylife=20m
        rekeymargin=3m
        keyingtries=1
        keyexchange=ikev1
        authby=secret
        ike=aes128-sha1-modp1024
        esp=aes128-sha1-modp1024

    conn AWS-VPN-1
        left=%defaultroute
        leftid=${var.onprem_public_ip}
        right=${aws_vpn_connection.main.tunnel1_address}
        type=tunnel
        leftsubnet=${var.onprem_cidr}
        rightsubnet=${var.vpc_cidr}
        auto=start
        
    conn AWS-VPN-2
        left=%defaultroute
        leftid=${var.onprem_public_ip}
        right=${aws_vpn_connection.main.tunnel2_address}
        type=tunnel
        leftsubnet=${var.onprem_cidr}
        rightsubnet=${var.vpc_cidr}
        auto=start
    EOL

    # Configure pre-shared keys
    cat > /etc/strongswan/ipsec.secrets <<'EOL'
    ${aws_vpn_connection.main.tunnel1_address} : PSK "${aws_vpn_connection.main.tunnel1_preshared_key}"
    ${aws_vpn_connection.main.tunnel2_address} : PSK "${aws_vpn_connection.main.tunnel2_preshared_key}"
    EOL

    systemctl restart strongswan
    EOF
}