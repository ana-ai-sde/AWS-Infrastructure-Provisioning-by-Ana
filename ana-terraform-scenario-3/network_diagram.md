# AWS VPC Network Architecture - Mumbai Region (ap-south-1)

## Infrastructure Diagram
```
                                    +-------------------+
                                    |                   |
                                    |    Internet       |
                                    |                   |
                                    +-------------------+
                                            |
                                            |
                                    +-------------------+
                                    | Internet Gateway  |
                                    +-------------------+
                                            |
                    +------------------------+------------------------+
                    |                        |                       |
            +---------------+        +---------------+               |
            | Public        |        | Public        |              |
            | Subnet 1      |        | Subnet 2      |              |
            | 10.0.1.0/24  |        | 10.0.2.0/24  |              |
            | (AZ-1)       |        | (AZ-2)       |              |
            +---------------+        +---------------+              |
                    |                                              |
                    |                                              |
            +---------------+                                      |
            | NAT Gateway   |                                      |
            | (in Public-1) |                                      |
            +---------------+                                      |
                    |                        VPC                   |
                    |                    10.0.0.0/16              |
            +---------------+        +---------------+             |
            | Private       |        | Private       |             |
            | Subnet 1      |        | Subnet 2      |             |
            | 10.0.3.0/24  |        | 10.0.4.0/24  |             |
            | (AZ-1)       |        | (AZ-2)       |             |
            +---------------+        +---------------+             |
                                                                  |
                    +-------------------------------------------|

```

## Component Details

### VPC Configuration
- **CIDR Block**: 10.0.0.0/16
- **Region**: ap-south-1 (Mumbai)
- **DNS Hostnames**: Enabled
- **DNS Support**: Enabled

### Subnet Layout
1. **Public Subnets**
   - Public Subnet 1: 10.0.1.0/24 (AZ-1)
   - Public Subnet 2: 10.0.2.0/24 (AZ-2)
   - Features:
     * Auto-assign public IPv4 address
     * Direct route to Internet Gateway

2. **Private Subnets**
   - Private Subnet 1: 10.0.3.0/24 (AZ-1)
   - Private Subnet 2: 10.0.4.0/24 (AZ-2)
   - Features:
     * No public IP auto-assignment
     * Outbound internet via NAT Gateway

### Network Components
1. **Internet Gateway**
   - Attached to VPC
   - Enables internet access for public subnets
   - Used by public route table

2. **NAT Gateway**
   - Located in Public Subnet 1
   - Uses Elastic IP
   - Enables outbound internet for private subnets
   - High availability design

### Routing Configuration
1. **Public Route Table**
   - Associated with both public subnets
   - Routes:
     * Local traffic (10.0.0.0/16) → Local
     * Internet traffic (0.0.0.0/0) → Internet Gateway

2. **Private Route Table**
   - Associated with both private subnets
   - Routes:
     * Local traffic (10.0.0.0/16) → Local
     * Internet traffic (0.0.0.0/0) → NAT Gateway

## High Availability Features
- Resources distributed across two Availability Zones
- NAT Gateway in Public Subnet 1 serves both private subnets
- Each subnet in a different AZ for fault tolerance

## Security Considerations
- Private subnets isolated from direct internet access
- NAT Gateway provides secure outbound internet access
- Public subnets can be accessed from internet (with proper security groups)