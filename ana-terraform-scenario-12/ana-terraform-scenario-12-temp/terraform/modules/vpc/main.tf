locals {
  name = var.cluster_name
  tags = {
    Environment = var.environment
    Terraform   = "true"
    Project     = var.project_name
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-vpc"
    }
  )
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    local.tags,
    {
      Name                                          = "${local.name}-private-${var.availability_zones[count.index]}"
      "kubernetes.io/cluster/${var.cluster_name}"   = "shared"
      "kubernetes.io/role/internal-elb"             = "1"
    }
  )
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    {
      Name                                          = "${local.name}-public-${var.availability_zones[count.index]}"
      "kubernetes.io/cluster/${var.cluster_name}"   = "shared"
      "kubernetes.io/role/elb"                      = "1"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-igw"
    }
  )
}

resource "aws_eip" "nat" {
  count = length(var.private_subnets)
  vpc   = true

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-nat-${count.index + 1}"
    }
  )
}

resource "aws_nat_gateway" "main" {
  count         = length(var.private_subnets)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-nat-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-public"
    }
  )
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-private-${count.index + 1}"
    }
  )
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}