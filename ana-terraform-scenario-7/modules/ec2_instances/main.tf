# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security Group for EC2 instances
resource "aws_security_group" "instance_sg" {
  name        = "instance-sg-${var.environment}"
  description = "Security group for monitored instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "instance-sg-${var.environment}"
    Environment = var.environment
  }
}

# Launch Template for EC2 instances
resource "aws_launch_template" "instance_template" {
  name_prefix   = "monitored-instance-${var.environment}"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.instance_sg.id]
  }

  iam_instance_profile {
    name = var.cloudwatch_agent_profile_name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y amazon-cloudwatch-agent
              
              # Download CloudWatch Agent configuration from SSM Parameter Store
              aws ssm get-parameter \
                --name ${var.cloudwatch_agent_config_param} \
                --region ${var.aws_region} \
                --output text \
                --query Parameter.Value > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

              # Start CloudWatch Agent
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
                -a fetch-config \
                -m ec2 \
                -s \
                -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

              systemctl enable amazon-cloudwatch-agent
              systemctl start amazon-cloudwatch-agent
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "monitored-instance-${var.environment}"
      Environment = var.environment
    }
  }

  tags = {
    Name        = "monitored-instance-template-${var.environment}"
    Environment = var.environment
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "instance_asg" {
  name                = "monitored-asg-${var.environment}"
  desired_capacity    = var.instance_count
  max_size           = var.instance_count * 2
  min_size           = var.instance_count
  target_group_arns  = []
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.instance_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "monitored-instance-${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}