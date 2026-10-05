## Summary
Document the system architecture and security decisions before writing infrastructure code.

## Prerequisites
- Issue #1 closed — README and repo guardrails in place

## What we are doing today
You write two documentation files that explain *how* the data lake is designed and *why* security choices were made. This is design-first cloud engineering — code comes later.

## Why it matters
Employers want judgement, not just Terraform. Architecture docs show you understand medallion zones, IAM separation, and cost-aware networking. Security docs prove you think about encryption, audit, and least privilege before clicking in the console.

## Step-by-step instructions

### Step 1 — Create docs folder
```bash
mkdir -p docs
```

### Step 2 — docs/architecture.md
Write sections covering:
1. **Overview** — extends prior data engineering work; moves storage and automation to AWS.
2. **Data flow** — EventBridge → Ingest Lambda → S3 `raw/` → S3 event → Clean Lambda → `clean/` + `curated/` + `quarantine/` → Glue Crawler → Athena.
3. **S3 layout** — show paths like `raw/owid/ingest_date=YYYY-MM-DD/`, `clean/{indicator}/year=YYYY/`, `curated/dim_region/`, `quarantine/rejected/`.
4. **Bucket strategy** — one bucket per environment (dev vs prod), zone prefixes inside each bucket; explain why dev and prod never share a bucket.
5. **Optional VPC** — ingest Lambda outside VPC; clean Lambda optionally inside; S3 gateway endpoint avoids NAT cost.

### Step 3 — docs/security-decisions.md
Write sections covering:
1. **Encryption** — SSE-S3 at rest; bucket policy denies non-HTTPS.
2. **Public access** — blocked on all buckets.
3. **IAM roles** — separate ingest, clean, reporting, and Glue crawler roles with least privilege.
4. **Audit** — CloudTrail and S3 access logging to a dedicated logs bucket.
5. **CI/CD** — GitHub OIDC instead of long-lived AWS keys (planned for Day 14).

## Files to create
- `docs/architecture.md`
- `docs/security-decisions.md`

## Done when
- [ ] Architecture doc explains data flow and S3 zones
- [ ] Security doc lists encryption, IAM, and audit choices
- [ ] Both files pushed to `main`

## AWS required?
No
