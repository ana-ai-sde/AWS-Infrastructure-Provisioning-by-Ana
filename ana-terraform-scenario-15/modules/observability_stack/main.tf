resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "tempo" {
  bucket = "${var.environment}-${random_string.bucket_suffix.result}-tempo-traces"
}

resource "aws_s3_bucket" "loki" {
  bucket = "${var.environment}-${random_string.bucket_suffix.result}-loki-logs"
}

resource "aws_s3_bucket_versioning" "tempo" {
  bucket = aws_s3_bucket.tempo.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "loki" {
  bucket = aws_s3_bucket.loki.id
  versioning_configuration {
    status = "Enabled"
  }
}