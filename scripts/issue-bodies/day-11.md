## Summary
Create the Terraform analytics module: Glue Data Catalog, on-demand crawler, and Athena workgroup.

## Prerequisites
- Issue #10 closed — ingestion Terraform module exists

## What we are doing today
You make S3 Parquet queryable by registering schemas in Glue and configuring an Athena workgroup with scan limits.

## Why it matters
Raw storage alone is not a data lake — discoverability and SQL access matter. The on-demand crawler (no schedule) is triggered by the clean Lambda after each run, keeping catalog fresh without extra cost.

## Step-by-step instructions

### Step 1 — Create analytics module folder
```bash
mkdir -p terraform/modules/analytics
```

### Step 2 — terraform/modules/analytics/variables.tf
Define: env, region, account_id, data lake bucket name/arn, athena bytes scanned limit.

### Step 3 — terraform/modules/analytics/main.tf
Implement:
1. **Glue database** — `health_lake_{env}`.
2. **Glue crawler IAM role** — read clean/ and curated/; write Glue catalog.
3. **Glue crawler** — targets `s3://{bucket}/clean/` and `curated/`; **empty schedule** (on-demand only).
4. **Athena workgroup** — `health-lake-{env}`; output to `athena-results/`; enforce scan byte limit; SSE-S3 on results.

### Step 4 — terraform/modules/analytics/outputs.tf
Export: glue database name, crawler name/arn, athena workgroup name.

## Files to create
- `terraform/modules/analytics/variables.tf`
- `terraform/modules/analytics/main.tf`
- `terraform/modules/analytics/outputs.tf`

## Done when
- [ ] Crawler has no schedule (on-demand via clean Lambda)
- [ ] Athena workgroup has bytes_scanned_cutoff configured
- [ ] Files pushed to `main`

## AWS required?
No — Terraform code only.
