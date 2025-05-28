output "volume_id" {
  description = "The volume ID of the created EBS volume"
  value       = aws_ebs_volume.this.id
}

output "volume_arn" {
  description = "The ARN of the created EBS volume"
  value       = aws_ebs_volume.this.arn
}

output "volume_size" {
  description = "The size of the created EBS volume in GiBs"
  value       = aws_ebs_volume.this.size
}

output "volume_type" {
  description = "The type of the created EBS volume"
  value       = aws_ebs_volume.this.type
}

output "volume_iops" {
  description = "The amount of IOPS the volume supports"
  value       = aws_ebs_volume.this.iops
}

output "volume_throughput" {
  description = "The throughput that the volume supports, in MiB/s"
  value       = aws_ebs_volume.this.throughput
}