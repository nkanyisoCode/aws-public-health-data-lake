# SNS alerts, AWS Budget, CloudTrail, GuardDuty, AWS Config

resource "aws_sns_topic" "alerts" {
  name = "health-lake-alerts-${var.env}"
}

resource "aws_sns_topic_subscription" "email" {
  count = var.alert_email != null ? 1 : 0

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_budgets_budget" "monthly" {
  name         = "health-lake-${var.env}-monthly"
  budget_type  = "COST"
  limit_amount = var.monthly_budget_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "TagKeyValue"
    values = ["project$health-lake"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.alert_email != null ? [var.alert_email] : []
  }
}

resource "aws_cloudtrail" "main" {
  name                          = "health-lake-trail-${var.env}"
  s3_bucket_name                = var.logs_bucket_id
  s3_key_prefix                 = "cloudtrail/"
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["${var.data_lake_bucket_arn}/"]
    }
  }

  depends_on = [aws_s3_bucket_policy.logs]
}

data "aws_iam_policy_document" "logs_bucket" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    actions = ["s3:GetBucketAcl"]
    resources = [var.logs_bucket_arn]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["${var.logs_bucket_arn}/cloudtrail/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  dynamic "statement" {
    for_each = var.enable_config ? [1] : []
    content {
      sid    = "AWSConfigBucketDelivery"
      effect = "Allow"
      actions = ["s3:PutObject", "s3:GetBucketAcl"]
      resources = [var.logs_bucket_arn, "${var.logs_bucket_arn}/config/*"]
      principals {
        type        = "Service"
        identifiers = ["config.amazonaws.com"]
      }
      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [var.account_id]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = var.logs_bucket_id
  policy = data.aws_iam_policy_document.logs_bucket.json
}

resource "aws_guardduty_detector" "main" {
  count  = var.enable_guardduty ? 1 : 0
  enable = true
}

resource "aws_iam_role" "config" {
  count = var.enable_config ? 1 : 0
  name  = "health-lake-config-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "config.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "config" {
  count      = var.enable_config ? 1 : 0
  role       = aws_iam_role.config[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_configuration_recorder" "main" {
  count    = var.enable_config ? 1 : 0
  name     = "health-lake-config-${var.env}"
  role_arn = aws_iam_role.config[0].arn

  recording_group {
    all_supported = true
  }
}

resource "aws_config_delivery_channel" "main" {
  count          = var.enable_config ? 1 : 0
  name           = "health-lake-config-${var.env}"
  s3_bucket_name = var.logs_bucket_id
  s3_key_prefix  = "config/"

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_configuration_recorder_status" "main" {
  count      = var.enable_config ? 1 : 0
  name       = aws_config_configuration_recorder.main[0].name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.main]
}

locals {
  config_rules = {
    s3_no_public_read = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
    s3_encryption     = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
    s3_ssl_only       = "S3_BUCKET_SSL_REQUESTS_ONLY"
    rds_encrypted     = "RDS_STORAGE_ENCRYPTED"
    rds_no_public     = "RDS_INSTANCE_PUBLIC_ACCESS_CHECK"
  }
}

resource "aws_config_config_rule" "managed" {
  for_each = var.enable_config ? local.config_rules : {}

  name = "${each.key}-${var.env}"

  source {
    owner             = "AWS"
    source_identifier = each.value
  }

  depends_on = [aws_config_configuration_recorder_status.main]
}
