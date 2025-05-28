# IAM Role for VPC Flow Logs
    resource "aws_iam_role" "flow_logs" {
        name = "${var.environment}-flow-logs-role"

        assume_role_policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
                {
                    Effect = "Allow"
                    Principal = {
                        Service = "vpc-flow-logs.amazonaws.com"
                    }
                    Action = "sts:AssumeRole"
                }
            ]
        })
    }

    resource "aws_iam_role_policy" "flow_logs" {
        name = "${var.environment}-flow-logs-policy"
        role = aws_iam_role.flow_logs.id

        policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
                {
                    Effect = "Allow"
                    Action = [
                        "logs:CreateLogGroup",
                        "logs:CreateLogStream",
                        "logs:PutLogEvents",
                        "logs:DescribeLogGroups",
                        "logs:DescribeLogStreams"
                    ]
                    Resource = "*"
                }
            ]
        })
    }

    # CloudWatch Log Groups
    resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
        name              = "/aws/vpc/flow-logs/${var.environment}"
        retention_in_days = var.waf_log_retention
    }

    # VPC Flow Logs
    resource "aws_flow_log" "main" {
        log_destination          = aws_cloudwatch_log_group.vpc_flow_logs.arn
        log_destination_type     = "cloud-watch-logs"
        traffic_type             = "ALL"
        vpc_id                   = var.vpc_id
        iam_role_arn            = aws_iam_role.flow_logs.arn
        max_aggregation_interval = 600
    }

    # Security Hub
    resource "aws_securityhub_account" "main" {}

    resource "aws_securityhub_standards_subscription" "cis" {
        depends_on    = [aws_securityhub_account.main]
        standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
    }

    # Get current AWS account ID
    data "aws_caller_identity" "current" {}

    # WAF Web ACL
    resource "aws_wafv2_web_acl" "main" {
        name        = "${var.environment}-web-acl"
        description = "WAF Web ACL for Zero Trust infrastructure"
        scope       = "REGIONAL"

        default_action {
            block {}
        }

        rule {
            name     = "RateLimitRule"
            priority = 1

            action {
                block {}
            }

            statement {
                rate_based_statement {
                    limit              = 2000
                    aggregate_key_type = "IP"
                }
            }

            visibility_config {
                cloudwatch_metrics_enabled = true
                metric_name               = "RateLimitRule"
                sampled_requests_enabled  = true
            }
        }

        rule {
            name     = "AWSManagedRulesCommonRuleSet"
            priority = 2

            override_action {
                none {}
            }

            statement {
                managed_rule_group_statement {
                    name        = "AWSManagedRulesCommonRuleSet"
                    vendor_name = "AWS"
                }
            }

            visibility_config {
                cloudwatch_metrics_enabled = true
                metric_name               = "AWSManagedRulesCommonRuleSetMetric"
                sampled_requests_enabled  = true
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name               = "WAFWebACLMetric"
            sampled_requests_enabled  = true
        }
    }

    # GuardDuty Configuration
    resource "aws_guardduty_detector" "main" {
        enable = true

        datasources {
            s3_logs {
                enable = true
            }
            kubernetes {
                audit_logs {
                    enable = true
                }
            }
            malware_protection {
                scan_ec2_instance_with_findings {
                    ebs_volumes {
                        enable = true
                    }
                }
            }
        }
    }