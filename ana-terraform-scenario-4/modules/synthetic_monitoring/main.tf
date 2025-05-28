# Ensure the canary directory exists
resource "local_file" "ensure_canary_dir" {
  filename = "${path.module}/canary/.keep"
  content  = ""

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/canary"
  }
}

# Create the canary script file
resource "local_file" "canary_script" {
  filename = "${path.module}/canary/script.js"
  content  = <<-EOF
const synthetics = require('Synthetics');
const log = require('SyntheticsLogger');

const pageLoadBlueprint = async function () {
    const URL = '${var.url_to_monitor}';
    
    log.info('Starting URL monitoring for: ' + URL);
    const page = await synthetics.getPage();
    
    const response = await page.goto(URL, {
        waitUntil: 'domcontentloaded',
        timeout: 30000
    });
    
    if (response.status() < 200 || response.status() > 299) {
        log.error('Failed to load page with status code: ' + response.status());
        throw new Error('Failed to load page with status code: ' + response.status());
    }
    
    log.info('Successfully loaded page with status code: ' + response.status());
    return 0;
};

exports.handler = async () => {
    return await pageLoadBlueprint();
};
EOF

  depends_on = [local_file.ensure_canary_dir]
}

# Create zip file from the script
data "archive_file" "canary_zip" {
  type        = "zip"
  source_file = local_file.canary_script.filename
  output_path = "${path.module}/canary/script.zip"

  depends_on = [local_file.canary_script]
}

resource "aws_s3_object" "canary_script" {
  bucket = aws_s3_bucket.canary_bucket.id
  key    = "canary/script.zip"
  source = data.archive_file.canary_zip.output_path

  depends_on = [data.archive_file.canary_zip]
}

resource "aws_synthetics_canary" "url_monitor" {
  name                 = var.monitoring_name
  artifact_s3_location = "s3://${aws_s3_bucket.canary_bucket.id}/artifacts/"
  execution_role_arn   = aws_iam_role.canary_role.arn
  handler              = "script.handler"
  runtime_version      = "syn-nodejs-puppeteer-10.0"
  
  schedule {
    expression = var.schedule_expression
  }

  run_config {
    timeout_in_seconds = 60
    memory_in_mb      = 960
    active_tracing    = true
  }

  zip_file = data.archive_file.canary_zip.output_path

  start_canary = true

  depends_on = [aws_iam_role_policy_attachment.cloudwatch_policy]
}

resource "aws_s3_bucket" "canary_bucket" {
  bucket_prefix = "cloudwatch-synthetics-artifacts-"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "canary_bucket_versioning" {
  bucket = aws_s3_bucket.canary_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "canary_role" {
  name = "${var.monitoring_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "synthetics.amazonaws.com"
          ]
        }
      }
    ]
  })

  inline_policy {
    name = "${var.monitoring_name}-s3-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:ListBucket"
          ]
          Resource = [
            aws_s3_bucket.canary_bucket.arn,
            "${aws_s3_bucket.canary_bucket.arn}/*"
          ]
        }
      ]
    })
  }
}

# Attach CloudWatch policy
resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  role       = aws_iam_role.canary_role.name
}