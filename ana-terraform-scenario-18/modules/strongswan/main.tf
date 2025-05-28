data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "strongswan" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type              = var.instance_type
  subnet_id                  = var.subnet_id
  associate_public_ip_address = true
  
  user_data = templatefile(var.user_data_template, {
    name = var.name
  })

  vpc_security_group_ids = [aws_security_group.strongswan.id]

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-strongswan"
    }
  )
}

resource "aws_security_group" "strongswan" {
  name        = "${var.name}-strongswan-sg"
  description = "Security group for StrongSwan VPN server"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}