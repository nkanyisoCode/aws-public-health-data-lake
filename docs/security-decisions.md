# Security Decisions

## Encryption

| Layer | Decision |
|-------|----------|
| At rest | SSE-S3 (AES256) on all buckets by default |
| In transit | Bucket policy denies all requests where `aws:SecureTransport = false` |
| RDS | `storage_encrypted = true`; credentials in Secrets Manager |

KMS (SSE-KMS) was not chosen to keep the student project simple and avoid key policy complexity. Upgrade path: add a CMK in `modules/data_lake` and reference it in bucket encryption and IAM policies.

## Public access

- S3 Block Public Access enabled on data lake and logs buckets.
- No static website hosting, no public ACLs.
- AWS Config rule `S3_BUCKET_PUBLIC_READ_PROHIBITED` when `enable_config = true`.

## IAM least privilege

Three pipeline roles plus one reporting role:

| Role | Can do | Cannot do |
|------|--------|-----------|
| `health-lake-ingest-{env}` | `PutObject` to `raw/*` | Write `clean/`, `curated/`, read secrets |
| `health-lake-clean-{env}` | Read `raw/*`, write `clean/`, `curated/`, `quarantine/` | Write `raw/` |
| `health-lake-reporting-{env}` | Read `clean/`, `curated/`; Athena + Glue read | Any write |
| `health-lake-glue-crawler-{env}` | Read S3 clean/curated; Glue catalog write | Write S3 |

Prove denial with `scripts/test_iam_least_privilege.sh` and screenshot `AccessDenied` results.

## Audit

- **CloudTrail** — management events + S3 data events on the data lake bucket; logs to the dedicated logs bucket.
- **S3 server access logging** — data lake bucket → logs bucket under `s3-access/`.
- **GuardDuty** — optional (`enable_guardduty`); enable for demo screenshots, disable to save cost.

## CI/CD authentication

GitHub Actions uses **OIDC** (`sts:AssumeRoleWithWebIdentity`) — no long-lived AWS access keys in GitHub secrets.

- **Plan role** — read-only (`terraform plan`, state lock).
- **Apply role** — `PowerUserAccess` attached (broader than ideal; tighten to specific services before production use).

Set repository variables `AWS_PLAN_ROLE_ARN` and `AWS_APPLY_ROLE_ARN` after enabling `enable_github_oidc`.

## checkov findings

| Check | Finding | Decision |
|-------|---------|----------|
| CKV_AWS_18 | S3 access logging on logs bucket itself | **Accepted** — logging bucket does not log to itself (infinite loop). Documented here. |
| CKV_AWS_145 | SSE-KMS vs SSE-S3 | **Accepted** — SSE-S3 for cost/simplicity; see encryption table. |
| CKV_AWS_117 | Lambda in VPC | **Conditional** — only when `enable_network = true`; required for private RDS access. |
| GitHub apply PowerUserAccess | Broad write scope | **Accepted for learning** — scope down to `s3:*`, `lambda:*`, `iam:*` on project ARNs before prod. |

Run locally: `pip install checkov && checkov -d terraform --framework terraform`

## Root account

- MFA enabled on root (manual step in AWS console).
- Day-to-day work through IAM user or SSO — never root for Terraform or CLI.

## Credentials in Git

- Never commit `.env`, `*.pem`, or AWS profiles.
- `.gitignore` excludes `.aws/` and `.env`.
- Lambda uses execution roles; local scripts use `aws configure` profile or environment variables.
