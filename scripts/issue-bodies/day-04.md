## What we are doing today

Day 4 adds **bootstrap scripts** — small shell utilities that support deployment later. You are not deploying yet; you are preparing the tools.

## Why it matters

- **`bootstrap_tf_state.sh`** — creates the S3 bucket that stores Terraform state (required before `terraform init` with remote backend).
- **`region_aliases.csv`** — reference data carried over from your data engineering project for region name standardisation during cleaning.

## Instructions

### Step 1 — Create scripts folder
```bash
mkdir -p scripts
```

### Step 2 — bootstrap_tf_state.sh
1. Create the file and paste from local project.
2. Make executable: `chmod +x scripts/bootstrap_tf_state.sh`
3. **Do not run yet** unless you have an AWS account — save for after Day 14.

### Step 3 — region_aliases.csv
1. Create the file and paste from local project (or copy from `public-health-etl-pipeline`).
2. This maps alternate region names to ISO codes during the clean step.

## Done when
- [ ] `scripts/bootstrap_tf_state.sh` is executable
- [ ] `scripts/region_aliases.csv` present
- [ ] Files pushed to GitHub

## AWS required?
No today. Run bootstrap script only when AWS account is ready.
