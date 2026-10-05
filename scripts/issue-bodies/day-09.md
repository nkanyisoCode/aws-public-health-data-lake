## Summary
Create the Terraform S3 data lake module — buckets, security, lifecycle rules, and zone prefixes.

## Prerequisites
- Issue #8 closed — SQL queries exist in `sql/`

## What we are doing today
You start Infrastructure as Code by defining the S3 storage layer: the data lake bucket with raw/clean/curated/quarantine prefixes, a separate logs bucket, encryption, lifecycle rules, and HTTPS-only bucket policy.

## Why it matters
Everything else in the project depends on secure, cost-aware storage. This module is the foundation — repeatable, reviewable, and deployable with one Terraform apply.

## Step-by-step instructions

### Step 1 — Create module structure
```bash
mkdir -p terraform/modules/data_lake
mkdir -p terraform/envs/dev
```

### Step 2 — terraform/modules/data_lake/variables.tf
Define inputs: `env`, `owner`, `account_id`, optional `s3_vpce_id` for VPC endpoint restriction on curated reads.

### Step 3 — terraform/modules/data_lake/main.tf
Implement:

1. **Data lake S3 bucket** — name pattern `{owner}-health-lake-{env}-{account_id}`.
2. **Block all public access** on the bucket.
3. **Enable versioning** for recoverability on raw data.
4. **Default encryption** — SSE-S3 (AES256).
5. **Lifecycle rules:**
   - `raw/` → Standard-IA at 30 days → Glacier at 90 days; expire noncurrent versions at 90 days
   - `athena-results/` → expire after 7 days
   - `quarantine/` → expire after 30 days
6. **Logs bucket** — separate bucket for S3 access logs.
7. **Server access logging** — data lake bucket logs to logs bucket under `s3-access/`.
8. **Bucket policy** — deny requests where `aws:SecureTransport` is false; optionally deny curated reads outside VPC endpoint when `s3_vpce_id` is set.

### Step 4 — terraform/modules/data_lake/outputs.tf
Export: bucket id, arn, name; logs bucket id and arn.

Optional: `terraform fmt -check terraform/modules/data_lake/`

## Files to create
- `terraform/modules/data_lake/variables.tf`
- `terraform/modules/data_lake/main.tf`
- `terraform/modules/data_lake/outputs.tf`

## Done when
- [ ] Module defines raw, clean, curated, quarantine, and athena-results prefixes via lifecycle filters
- [ ] Public access blocked and HTTPS-only policy in place
- [ ] You can explain why logs get a separate bucket
- [ ] Files pushed to `main`

## AWS required?
No — Terraform code only. `terraform apply` comes after dev env wiring (Day 13).
