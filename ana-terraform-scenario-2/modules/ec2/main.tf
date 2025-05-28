data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "monitoring_instance" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  iam_instance_profile        = var.instance_profile
  vpc_security_group_ids      = [var.security_group_id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  root_block_device {
    encrypted   = true
    volume_size = 20
    volume_type = "gp3"
    tags        = var.tags
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y amazon-cloudwatch-agent

              # Fetch configuration from SSM Parameter Store and start the agent
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:${var.ssm_parameter_name}
              systemctl start amazon-cloudwatch-agent
              EOF

  tags = merge(
    var.tags,
    {
      Name = "monitoring-instance-${var.environment}"
    }
  )

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      ami,
      user_data
    ]
  }
}

# EC2 Instance Connect Endpoint for secure SSH access
resource "aws_ec2_instance_connect_endpoint" "monitoring" {
  subnet_id          = var.subnet_id
  security_group_ids = [var.security_group_id]
  
  tags = merge(
    var.tags,
    {
      Name = "monitoring-instance-connect-${var.environment}"
    }
  )
}