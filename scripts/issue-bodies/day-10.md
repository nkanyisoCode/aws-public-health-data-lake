## Summary
Create the Terraform ingestion module: Lambdas, EventBridge schedule, S3 event trigger, and IAM roles.

## Prerequisites
- Issue #9 closed — data lake Terraform module exists
- Lambda code from Days 5–6 in `lambda/ingest/` and `lambda/clean/`

## What we are doing today
You wire the Python handlers into AWS: scheduled ingest Lambda, event-driven clean Lambda, least-privilege IAM, and CloudWatch alarms on failures.

## Why it matters
This is the automation layer — weekly ingest with zero manual steps after deploy. The S3 event notification on `raw/*.csv` is a key enhancement: new files automatically trigger cleaning.

## Step-by-step instructions

### Step 1 — Create ingestion module folder
```bash
mkdir -p terraform/modules/ingestion
```

### Step 2 — terraform/modules/ingestion/variables.tf
Define: env, account_id, data lake bucket id/name/arn, ingest schedule, SNS topic arn, Glue crawler name/arn, optional VPC subnet and security group ids, optional RDS secret arn.

### Step 3 — terraform/modules/ingestion/main.tf
Implement:

**Ingest Lambda (no VPC):**
- Package from `lambda/ingest/`
- IAM role: write to `raw/*` only
- EventBridge cron rule (weekly)
- CloudWatch alarm on errors → SNS

**Clean Lambda (optional VPC):**
- Package from `lambda/clean/`
- IAM role: read raw/, write clean/ curated/ quarantine/, start Glue crawler
- S3 bucket notification: `ObjectCreated` on `raw/` suffix `.csv` → invoke clean Lambda
- CloudWatch alarm on errors → SNS

**Reporting role:**
- Read-only on clean/ and curated/; Athena and Glue read permissions

Use `archive_file` data source to zip Lambda folders.

### Step 4 — terraform/modules/ingestion/outputs.tf
Export: Lambda names/arns, role arns, reporting role arn.

## Files to create
- `terraform/modules/ingestion/variables.tf`
- `terraform/modules/ingestion/main.tf`
- `terraform/modules/ingestion/outputs.tf`

## Done when
- [ ] S3 event notification triggers clean Lambda on raw CSV upload
- [ ] Ingest and clean roles follow least-privilege paths
- [ ] EventBridge schedule targets ingest Lambda
- [ ] Files pushed to `main`

## AWS required?
No — Terraform code only.
