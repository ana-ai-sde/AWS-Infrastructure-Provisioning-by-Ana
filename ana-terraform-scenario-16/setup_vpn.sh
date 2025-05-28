#!/bin/bash

# Install strongSwan
sudo yum update -y
sudo yum install -y strongswan

# Configure strongSwan
sudo tee /etc/strongswan/ipsec.conf <<'EOL'
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
    leftid=52.66.163.205
    right=3.111.69.237
    type=tunnel
    leftsubnet=192.168.0.0/16
    rightsubnet=10.0.0.0/16
    auto=start

conn AWS-VPN-2
    left=%defaultroute
    leftid=52.66.163.205
    right=43.204.188.69
    type=tunnel
    leftsubnet=192.168.0.0/16
    rightsubnet=10.0.0.0/16
    auto=start
EOL

# Configure pre-shared keys
sudo tee /etc/strongswan/ipsec.secrets <<'EOL'
3.111.69.237 : PSK "dfrynRGBvboAMnG0uBcWeiCiiCCmy6xE"
43.204.188.69 : PSK "IfaGt1mTLyp3dsRgaRdEohA5x9dQYnAj"
EOL

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Start strongSwan
sudo systemctl enable strongswan
sudo systemctl restart strongswan

# Wait for tunnels to establish
sleep 10

# Check VPN status
sudo strongswan status

# Create ping test script
sudo tee /root/test_vpn.sh <<'EOL'
#!/bin/bash

echo "Testing VPN connection..."
echo "StrongSwan Status:"
strongswan status

echo -e "\nPinging AWS instance (10.0.2.138)..."
ping -c 4 10.0.2.138
EOL

sudo chmod +x /root/test_vpn.sh