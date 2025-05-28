#!/bin/bash

# Install required packages
yum update -y
yum install -y strongswan

# Configure strongSwan
cat > /etc/strongswan/ipsec.conf <<EOF
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
    leftid=${tunnel1_ip}
    right=${tunnel1_ip}
    type=tunnel
    leftsubnet=192.168.0.0/16
    rightsubnet=${vpc_cidr}
    auto=start
    
conn AWS-VPN-2
    left=%defaultroute
    leftid=${tunnel2_ip}
    right=${tunnel2_ip}
    type=tunnel
    leftsubnet=192.168.0.0/16
    rightsubnet=${vpc_cidr}
    auto=start
EOF

# Configure pre-shared keys
cat > /etc/strongswan/ipsec.secrets <<EOF
${tunnel1_ip} : PSK "${psk1}"
${tunnel2_ip} : PSK "${psk2}"
EOF

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# Start strongSwan
systemctl enable strongswan
systemctl start strongswan

# Create health check script
cat > /root/vpn_health_check.sh <<'EOF'
#!/bin/bash

# Function to check tunnel status
check_tunnel() {
    if ip xfrm state | grep -q "mode tunnel"; then
        echo "VPN tunnel is up"
        return 0
    else
        echo "VPN tunnel is down"
        return 1
    fi
}

# Function to ping AWS instance
ping_aws_instance() {
    local aws_ip=$1
    if ping -c 3 $aws_ip > /dev/null; then
        echo "Successfully pinged AWS instance at $aws_ip"
        return 0
    else
        echo "Failed to ping AWS instance at $aws_ip"
        return 1
    fi
}

# Main health check
echo "Starting VPN health check..."
check_tunnel
tunnel_status=$?

if [ $tunnel_status -eq 0 ]; then
    echo "Checking connectivity to AWS instance..."
    ping_aws_instance $1
    ping_status=$?
    
    if [ $ping_status -eq 0 ]; then
        echo "Health check passed!"
        exit 0
    else
        echo "Health check failed: Cannot ping AWS instance"
        exit 1
    fi
else
    echo "Health check failed: VPN tunnel is down"
    exit 1
fi
EOF

chmod +x /root/vpn_health_check.sh