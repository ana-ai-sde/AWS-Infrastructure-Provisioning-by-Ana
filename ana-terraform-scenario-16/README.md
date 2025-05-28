# AWS Site-to-Site VPN with strongSwan

This project sets up a Site-to-Site VPN connection between an AWS VPC and a simulated on-premises environment using strongSwan.

## Architecture

- AWS Side:
  - VPC with public and private subnets (10.0.0.0/16)
  - Virtual Private Gateway (VGW)
  - Customer Gateway (CGW)
  - EC2 instance in private subnet (10.0.2.138)
  - Route tables and security groups

- On-premises Side (Simulated):
  - EC2 instance with strongSwan (52.66.163.205)
  - IPsec VPN configuration
  - Simulated on-premises network (192.168.0.0/16)

## VPN Tunnel Information

- Tunnel 1:
  - AWS Endpoint: 3.111.69.237
  - Pre-shared Key: Configured in strongswan_config.sh

- Tunnel 2:
  - AWS Endpoint: 43.204.188.69
  - Pre-shared Key: Configured in strongswan_config.sh

## Setup Instructions

1. Infrastructure has been created using Terraform
2. To configure the VPN on the on-premises instance:
   ```bash
   # Copy setup_vpn.sh to the on-premises instance
   scp -i your-key.pem setup_vpn.sh ec2-user@52.66.163.205:~/

   # SSH into the on-premises instance
   ssh -i your-key.pem ec2-user@52.66.163.205

   # Run the setup script
   chmod +x setup_vpn.sh
   sudo ./setup_vpn.sh
   ```

3. To test the VPN connection:
   ```bash
   # On the on-premises instance
   sudo /root/test_vpn.sh
   ```

## Verification

The VPN connection is working properly if:
1. strongSwan shows both tunnels as ESTABLISHED
2. You can ping the AWS instance (10.0.2.138) from the on-premises instance
3. The AWS instance can ping the on-premises instance

## Cleanup

To destroy all resources:
```bash
terraform destroy -auto-approve
```

## Troubleshooting

1. Check VPN tunnel status:
   ```bash
   sudo strongswan status
   ```

2. View strongSwan logs:
   ```bash
   sudo tail -f /var/log/strongswan.log
   ```

3. Verify IP forwarding is enabled:
   ```bash
   cat /proc/sys/net/ipv4/ip_forward
   ```

4. Check security group rules are properly configured for ICMP and IPsec traffic