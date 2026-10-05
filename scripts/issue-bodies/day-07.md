## What we are doing today

Day 7 adds **helper scripts** for local testing and security proof. These mirror Lambda behaviour on your laptop and prepare IAM denial tests for after AWS deploy.

## Why it matters

- **`clean_s3.py`** — run the same cleaning logic locally against S3 (useful for debugging without redeploying Lambda).
- **`manual_ingest.sh`** — trigger ingestion manually when EventBridge is not due yet.
- **`test_iam_least_privilege.sh`** — portfolio proof that ingest role cannot write to `clean/` and reporting role cannot write anywhere.

## Instructions

### Step 1 — scripts/requirements.txt
1. Add Python deps for local scripts (boto3, pandas, pyarrow).

### Step 2 — clean_s3.py
1. Create and paste from local project.
2. `chmod +x scripts/clean_s3.py`
3. Usage (after AWS): `python scripts/clean_s3.py --bucket BUCKET --key raw/owid/...`

### Step 3 — manual_ingest.sh
1. Create, paste, `chmod +x`.
2. Usage (after AWS): `./scripts/manual_ingest.sh dev 2026-10-05 YOUR-BUCKET`

### Step 4 — test_iam_least_privilege.sh
1. Create, paste, `chmod +x`.
2. Run only after Terraform creates IAM roles.

## Done when
- [ ] All four script files in `scripts/`
- [ ] Shell scripts are executable
- [ ] Pushed to GitHub

## AWS required?
No for adding files. IAM test runs after deploy.
