data "archive_file" "ingest" {
  type        = "zip"
  source_dir  = "${path.module}/../../../lambda/ingest"
  output_path = "${path.module}/ingest.zip"
}

resource "terraform_data" "clean_lambda_package" {
  triggers_replace = {
    handler_sha = filemd5("${path.module}/../../../lambda/clean/handler.py")
    req_sha     = filemd5("${path.module}/../../../lambda/clean/requirements.txt")
    script_sha  = filemd5("${path.module}/build_clean_lambda.sh")
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/build_clean_lambda.sh"
  }
}

data "archive_file" "clean" {
  depends_on = [terraform_data.clean_lambda_package]

  type        = "zip"
  source_dir  = "${path.module}/clean_build"
  output_path = "${path.module}/clean.zip"
}

# ---------------------------------------------------------------------------
# Ingest Lambda — runs outside VPC (downloads public OWID data)
# ---------------------------------------------------------------------------

resource "aws_iam_role" "ingest" {
  name = "health-lake-ingest-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "ingest" {
  name = "health-lake-ingest-s3-${var.env}"
  role = aws_iam_role.ingest.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "WriteRawOnly"
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:PutObjectTagging"]
        Resource = "${var.data_lake_bucket_arn}/raw/*"
      },
      {
        Sid      = "ListBucketRaw"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = var.data_lake_bucket_arn
        Condition = {
          StringLike = {
            "s3:prefix" = ["raw/*"]
          }
        }
      },
      {
        Sid      = "CloudWatchLogs"
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_lambda_function" "ingest" {
  function_name = "health-lake-ingest-${var.env}"
  role          = aws_iam_role.ingest.arn
  handler       = "handler.handler"
  runtime       = "python3.12"
  timeout       = 120
  memory_size   = 256

  filename         = data.archive_file.ingest.output_path
  source_code_hash = data.archive_file.ingest.output_base64sha256

  environment {
    variables = {
      DATA_LAKE_BUCKET = var.data_lake_bucket_name
    }
  }
}

resource "aws_cloudwatch_event_rule" "weekly_ingest" {
  name                = "health-lake-weekly-ingest-${var.env}"
  description         = "Trigger OWID ingestion weekly"
  schedule_expression = var.ingest_schedule
}

resource "aws_cloudwatch_event_target" "weekly_ingest" {
  rule      = aws_cloudwatch_event_rule.weekly_ingest.name
  target_id = "ingest-lambda"
  arn       = aws_lambda_function.ingest.arn
}

resource "aws_lambda_permission" "eventbridge_ingest" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingest.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.weekly_ingest.arn
}

resource "aws_cloudwatch_metric_alarm" "ingest_errors" {
  alarm_name          = "health-lake-ingest-errors-${var.env}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Ingest Lambda failed"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.ingest.function_name
  }

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
}

# ---------------------------------------------------------------------------
# Clean Lambda — triggered by S3 event when new raw CSV lands
# ---------------------------------------------------------------------------

resource "aws_iam_role" "clean" {
  name = "health-lake-clean-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "clean" {
  name = "health-lake-clean-s3-glue-${var.env}"
  role = aws_iam_role.clean.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadRaw"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [var.data_lake_bucket_arn, "${var.data_lake_bucket_arn}/raw/*"]
      },
      {
        Sid      = "WriteCleanCuratedQuarantine"
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:DeleteObject"]
        Resource = [
          "${var.data_lake_bucket_arn}/clean/*",
          "${var.data_lake_bucket_arn}/curated/*",
          "${var.data_lake_bucket_arn}/quarantine/*",
        ]
      },
      {
        Sid      = "StartGlueCrawler"
        Effect   = "Allow"
        Action   = ["glue:StartCrawler", "glue:GetCrawler"]
        Resource = var.glue_crawler_arn != null ? [var.glue_crawler_arn] : ["*"]
      },
      {
        Sid      = "CloudWatchLogs"
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Sid      = "VpcNetworking"
        Effect   = "Allow"
        Action   = ["ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface"]
        Resource = "*"
      },
      {
        Sid      = "SecretsManagerRead"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = var.rds_secret_arn != null ? [var.rds_secret_arn] : []
      }
    ]
  })
}

resource "aws_lambda_function" "clean" {
  function_name = "health-lake-clean-${var.env}"
  role          = aws_iam_role.clean.arn
  handler       = "handler.handler"
  runtime       = "python3.12"
  timeout       = 300
  memory_size   = 512

  filename         = data.archive_file.clean.output_path
  source_code_hash = data.archive_file.clean.output_base64sha256

  dynamic "vpc_config" {
    for_each = length(var.private_subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.private_subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  environment {
    variables = {
      DATA_LAKE_BUCKET  = var.data_lake_bucket_name
      GLUE_CRAWLER_NAME = var.glue_crawler_name
      RDS_SECRET_ARN    = var.rds_secret_arn != null ? var.rds_secret_arn : ""
    }
  }
}

# S3 event notification: new raw CSV → clean Lambda (event-driven pipeline)
resource "aws_lambda_permission" "s3_invoke_clean" {
  statement_id  = "AllowS3InvokeClean"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.clean.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.data_lake_bucket_arn
}

resource "aws_s3_bucket_notification" "raw_to_clean" {
  bucket = var.data_lake_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.clean.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "raw/"
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.s3_invoke_clean]
}

resource "aws_cloudwatch_metric_alarm" "clean_errors" {
  alarm_name          = "health-lake-clean-errors-${var.env}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Clean Lambda failed after raw file upload"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.clean.function_name
  }

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
}

# Reporting role — read-only access to clean and curated zones
resource "aws_iam_role" "reporting" {
  name = "health-lake-reporting-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${var.account_id}:root"
      }
      Condition = {
        StringEquals = {
          "aws:PrincipalType" = "User"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "reporting" {
  name = "health-lake-reporting-read-${var.env}"
  role = aws_iam_role.reporting.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadCleanCurated"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          var.data_lake_bucket_arn,
          "${var.data_lake_bucket_arn}/clean/*",
          "${var.data_lake_bucket_arn}/curated/*",
        ]
      },
      {
        Sid      = "AthenaQuery"
        Effect   = "Allow"
        Action   = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:StopQueryExecution",
          "athena:GetWorkGroup",
        ]
        Resource = "*"
      },
      {
        Sid      = "GlueRead"
        Effect   = "Allow"
        Action   = ["glue:GetDatabase", "glue:GetTable", "glue:GetTables"]
        Resource = "*"
      }
    ]
  })
}
