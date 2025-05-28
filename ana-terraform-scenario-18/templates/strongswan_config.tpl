#!/bin/bash

# Install StrongSwan
apt-get update
apt-get install -y strongswan

# Basic StrongSwan configuration
cat > /etc/ipsec.conf <<EOF
config setup
    charondebug="ike 2, knl 2, cfg 2, net 2, esp 2, dmn 2"
    uniqueids=no

conn %default
    ikelifetime=60m
    keylife=20m
    rekeymargin=3m
    keyingtries=3
    keyexchange=ikev2
    mobike=no
EOF

# Start StrongSwan service
systemctl enable strongswan
systemctl start strongswan