# GitHub Actions OIDC — no long-lived AWS keys in GitHub secrets

resource "aws_iam_openid_connect_provider" "github" {
  count = var.enable_github_oidc ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03fa05379b1d50909700b4cfc09"]
}

data "aws_iam_policy_document" "gha_trust" {
  count = var.enable_github_oidc ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github[0].arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "github_plan" {
  count = var.enable_github_oidc ? 1 : 0
  name  = "github-actions-terraform-plan-${var.env}"

  assume_role_policy = data.aws_iam_policy_document.gha_trust[0].json
}

resource "aws_iam_role" "github_apply" {
  count = var.enable_github_oidc ? 1 : 0
  name  = "github-actions-terraform-apply-${var.env}"

  assume_role_policy = data.aws_iam_policy_document.gha_trust[0].json
}

data "aws_iam_policy_document" "terraform_read" {
  statement {
    sid    = "TerraformReadOnly"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "ec2:Describe*",
      "iam:Get*",
      "iam:List*",
      "lambda:Get*",
      "lambda:List*",
      "glue:Get*",
      "glue:List*",
      "athena:Get*",
      "athena:List*",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "sns:Get*",
      "sns:List*",
      "events:Describe*",
      "events:List*",
      "budgets:ViewBudget",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetTrailStatus",
      "config:Describe*",
      "config:Get*",
      "config:List*",
      "guardduty:Get*",
      "guardduty:List*",
      "rds:Describe*",
      "kms:Describe*",
      "kms:List*",
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_plan" {
  count  = var.enable_github_oidc ? 1 : 0
  name   = "terraform-plan-read"
  role   = aws_iam_role.github_plan[0].id
  policy = data.aws_iam_policy_document.terraform_read.json
}

# Apply role needs write access — scope down in production
resource "aws_iam_role_policy_attachment" "github_apply" {
  count      = var.enable_github_oidc ? 1 : 0
  role       = aws_iam_role.github_apply[0].name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
