# Glue Data Catalog + on-demand crawler (no schedule — triggered by clean Lambda)

resource "aws_glue_catalog_database" "health_lake" {
  name        = "health_lake_${var.env}"
  description = "Public health data lake — clean and curated zones"
}

resource "aws_iam_role" "glue_crawler" {
  name = "health-lake-glue-crawler-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "glue.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "glue_crawler" {
  name = "health-lake-glue-s3-${var.env}"
  role = aws_iam_role.glue_crawler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadCleanCurated"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [var.data_lake_bucket_arn, "${var.data_lake_bucket_arn}/clean/*", "${var.data_lake_bucket_arn}/curated/*"]
      },
      {
        Sid      = "GlueCatalog"
        Effect   = "Allow"
        Action   = [
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetDatabase",
          "glue:CreatePartition",
          "glue:UpdatePartition",
          "glue:GetPartition",
          "glue:GetPartitions",
          "glue:BatchCreatePartition",
        ]
        Resource = [
          "arn:aws:glue:${var.region}:${var.account_id}:catalog",
          "arn:aws:glue:${var.region}:${var.account_id}:database/${aws_glue_catalog_database.health_lake.name}",
          "arn:aws:glue:${var.region}:${var.account_id}:table/${aws_glue_catalog_database.health_lake.name}/*",
        ]
      },
      {
        Sid      = "CloudWatchLogs"
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:/aws-glue/*"
      }
    ]
  })
}

resource "aws_glue_crawler" "clean_zone" {
  name          = "health-lake-clean-${var.env}"
  role          = aws_iam_role.glue_crawler.arn
  database_name = aws_glue_catalog_database.health_lake.name

  # On-demand only — no schedule. Clean Lambda calls StartCrawler after writing Parquet.
  schedule = ""

  s3_target {
    path = "s3://${var.data_lake_bucket_name}/clean/"
  }

  s3_target {
    path = "s3://${var.data_lake_bucket_name}/curated/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })
}

resource "aws_athena_workgroup" "health_lake" {
  name = "health-lake-${var.env}"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.data_lake_bucket_name}/athena-results/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }

    bytes_scanned_cutoff_per_query = var.athena_bytes_scanned_limit
  }

  force_destroy = true
}
