output "tempo_bucket" {
  description = "Name of the Tempo S3 bucket"
  value       = aws_s3_bucket.tempo.id
}

output "loki_bucket" {
  description = "Name of the Loki S3 bucket"
  value       = aws_s3_bucket.loki.id
}