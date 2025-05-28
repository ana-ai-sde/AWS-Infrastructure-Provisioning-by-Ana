# Create EC2 Instance
resource "aws_instance" "main" {
  ami                         = var.ami_id
  instance_type              = var.instance_type
  subnet_id                  = var.subnet_id
  vpc_security_group_ids     = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip
  key_name                   = var.key_name
  iam_instance_profile       = var.iam_role_name != null ? aws_iam_instance_profile.this[0].name : null

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = merge(
    {
      Name = "${var.environment}-ec2"
    },
    var.tags
  )
}

# Create IAM instance profile
resource "aws_iam_instance_profile" "this" {
  count = var.iam_role_name != null ? 1 : 0
  name  = "${var.environment}-ec2-profile"
  role  = var.iam_role_name
}