## Summary
Add local helper scripts for manual testing and IAM least-privilege verification.

## Prerequisites
- Issue #6 closed — clean Lambda code exists

## What we are doing today
You create scripts to run the cleaning pipeline locally against S3, manually trigger ingestion, and prove IAM roles cannot perform forbidden actions.

## Why it matters
Operators need tools beyond the AWS console. The IAM denial test is a portfolio proof point — screenshot `AccessDenied` when ingest role tries to write `clean/` or reporting role tries to write anywhere.

## Step-by-step instructions

### Step 1 — scripts/requirements.txt
List: `boto3`, `pandas`, `pyarrow`

### Step 2 — scripts/clean_s3.py
Write a CLI script that:
1. Accepts `--bucket`, `--key`, `--region`, optional `--crawler` arguments.
2. Reads a raw CSV from S3 and runs the same cleaning logic as the Lambda handler.
3. Prints stats: clean rows, rejected rows, parquet partitions written.
4. Uses `argparse` and reads `DATA_LAKE_BUCKET` from environment as default.

### Step 3 — scripts/manual_ingest.sh
Write a bash script that:
1. Accepts env name, ingest date, and bucket name as arguments.
2. Invokes `health-lake-ingest-{env}` Lambda with JSON payload `{"ingest_date": "..."}`.
3. Prints the response and reminds user that S3 event will trigger clean Lambda.

Make executable: `chmod +x scripts/manual_ingest.sh`

### Step 4 — scripts/test_iam_least_privilege.sh
Write a bash script that:
1. Assumes the ingest IAM role and attempts to write to `clean/` — expect AccessDenied.
2. Assumes the reporting IAM role and attempts to write to `curated/` — expect AccessDenied.
3. Prints instructions to screenshot results for portfolio.

Make executable: `chmod +x scripts/test_iam_least_privilege.sh`

## Files to create
- `scripts/requirements.txt`
- `scripts/clean_s3.py`
- `scripts/manual_ingest.sh`
- `scripts/test_iam_least_privilege.sh`

## Done when
- [ ] clean_s3.py accepts bucket and key arguments
- [ ] Both shell scripts are executable
- [ ] IAM test script documents expected AccessDenied behaviour
- [ ] Files pushed to `main`

## AWS required?
No for writing scripts. IAM test runs after Terraform deploy.
