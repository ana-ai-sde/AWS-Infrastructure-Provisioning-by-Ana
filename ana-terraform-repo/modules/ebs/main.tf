resource "aws_ebs_volume" "this" {
  availability_zone = var.availability_zone
  size             = var.size
  type             = var.type
  encrypted        = var.encrypted
  kms_key_id       = var.kms_key_id
  iops            = var.iops
  throughput      = var.throughput
  tags            = merge(
    {
      Name = "ebs-volume-${var.availability_zone}"
    },
    var.tags
  )

  lifecycle {
    prevent_destroy = false
  }
}