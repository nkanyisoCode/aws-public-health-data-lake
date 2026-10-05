## What we are doing today

Day 2 adds **architecture and security documentation**. You explain *how* the system is designed and *why* security choices were made — before writing infrastructure code. This is what separates a tutorial follow-along from a professional cloud portfolio.

## Why it matters

- **`architecture.md`** — documents the medallion data lake (raw → clean → curated), S3 layout, bucket-per-environment strategy, and optional VPC design.
- **`security-decisions.md`** — records encryption, IAM least privilege, audit logging, and CI/CD auth choices so reviewers see your judgement.

## Instructions

### Step 1 — Create docs folder
```bash
mkdir -p docs
```

### Step 2 — docs/architecture.md
1. Create the file and paste from your local complete project.
2. Read through it and replace `nkanyiso` with your name where needed.
3. Understand the three zones: `raw/` (immutable CSV), `clean/` (Parquet), `curated/` (star schema).

### Step 3 — docs/security-decisions.md
1. Create the file and paste from local project.
2. Note the three IAM roles: ingest (write raw only), clean (read raw, write clean/curated), reporting (read only).

## Done when
- [ ] `docs/architecture.md` explains data flow and S3 zones
- [ ] `docs/security-decisions.md` lists encryption and IAM decisions
- [ ] Both files pushed to GitHub

## AWS required?
No.
