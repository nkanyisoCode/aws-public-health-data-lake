## Summary
Add bootstrap scripts for Terraform state and region reference data.

## Prerequisites
- Issue #3 closed — cost and runbook docs exist

## What we are doing today
You create small shell utilities that support deployment later. You are not deploying to AWS yet — only preparing the tools.

## Why it matters
Terraform remote state in S3 is required for repeatable, team-safe infrastructure. The bootstrap script creates that bucket once, outside Terraform. Region aliases support consistent region names during data cleaning.

## Step-by-step instructions

### Step 1 — Create scripts folder
```bash
mkdir -p scripts
```

### Step 2 — scripts/bootstrap_tf_state.sh
1. Write a bash script that accepts owner name and region as arguments.
2. Create an S3 bucket named `{owner}-tfstate-{account_id}`.
3. Enable block public access, versioning, and default encryption (AES256).
4. Print the bucket name so the user can update `terraform/envs/dev/backend.tf` later.
5. Make executable: `chmod +x scripts/bootstrap_tf_state.sh`
6. **Do not run until you have an AWS account** (after Day 14).

### Step 3 — scripts/region_aliases.csv
1. Create a CSV with columns: `alias`, `iso_code`.
2. Add a few rows mapping alternate region names to ISO codes (e.g. common spelling variants).
3. This file supports region standardisation in the clean Lambda (Day 6).

## Files to create
- `scripts/bootstrap_tf_state.sh`
- `scripts/region_aliases.csv`

## Done when
- [ ] Bootstrap script is executable and documents its usage in comments
- [ ] Region aliases CSV has header row and sample mappings
- [ ] Files pushed to `main`

## AWS required?
No today. Run bootstrap script only when AWS account is ready.
