resource "aws_security_group" "onprem" {
  name        = "onprem-instance-sg"
  description = "Security group for on-premises EC2 instance"
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

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-onprem-instance-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "onprem" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_id

  associate_public_ip_address = true
  source_dest_check          = false

  vpc_security_group_ids = [aws_security_group.onprem.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y strongswan
              echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
              sysctl -p
              systemctl enable strongswan
              EOF

  tags = {
    Name        = "${var.environment}-onprem-instance"
    Environment = var.environment
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}