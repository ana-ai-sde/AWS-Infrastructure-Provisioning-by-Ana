# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = merge(
    {
      Name = "nat-gateway-eip"
    },
    var.tags
  )
}

# Create NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id

  tags = merge(
    {
      Name = "main-nat-gateway"
    },
    var.tags
  )

  depends_on = [aws_eip.nat]
}