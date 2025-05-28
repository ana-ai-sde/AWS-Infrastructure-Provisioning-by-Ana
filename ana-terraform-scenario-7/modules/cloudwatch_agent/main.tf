# IAM role for CloudWatch Agent
resource "aws_iam_role" "cloudwatch_agent_role" {
  name = "cloudwatch-agent-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Attach CloudWatch Agent policy to the role
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  role       = aws_iam_role.cloudwatch_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Create instance profile for the CloudWatch Agent role
resource "aws_iam_instance_profile" "cloudwatch_agent_profile" {
  name = "cloudwatch-agent-profile-${var.environment}"
  role = aws_iam_role.cloudwatch_agent_role.name
}

# SSM Parameter for CloudWatch Agent configuration
resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  name  = "/cloudwatch-agent/config/${var.environment}"
  type  = "String"
  value = file("${path.module}/config/agent-config.json")

  tags = {
    Environment = var.environment
  }
}