resource "aws_ssm_parameter" "cloudwatch_config" {
  name        = "/${var.environment}/cloudwatch-agent/config"
  description = "Configuration for CloudWatch agent"
  type        = "SecureString"
  value       = jsonencode({
    metrics = {
      metrics_collected = {
        cpu = {
          measurement = [
            "cpu_usage_idle",
            "cpu_usage_user",
            "cpu_usage_system"
          ]
          metrics_collection_interval = 60
        }
        mem = {
          measurement = [
            "mem_used_percent"
          ]
          metrics_collection_interval = 60
        }
      }
    }
  })

  tags = merge(
    var.tags,
    {
      Name = "cloudwatch-agent-config"
    }
  )
}