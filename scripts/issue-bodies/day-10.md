## What we are doing today

Day 10 adds the **ingestion Terraform module** — wires your Day 5 and Day 6 Lambda code into AWS with scheduling, IAM roles, and the key enhancement: **automatic cleaning when a new raw file arrives**.

## Why it matters

- **EventBridge** replaces Airflow/cron for weekly OWID downloads.
- **S3 event notification** triggers Clean Lambda — event-driven pipeline, no polling.
- **Least-privilege IAM** — separate roles for ingest, clean, and reporting.
- **CloudWatch alarms** → SNS email when either Lambda fails.

## Instructions

### Step 1 — Create module folder
```bash
mkdir -p terraform/modules/ingestion
```

### Step 2 — Add module files
1. `variables.tf`, `main.tf`, `outputs.tf` — paste from local project.

## What the module creates
| Resource | Purpose |
|----------|---------|
| Ingest Lambda | Downloads OWID → S3 raw/ (no VPC) |
| EventBridge rule | Weekly schedule (default: Monday 06:00 UTC) |
| Clean Lambda | Triggered by S3 event on raw/*.csv |
| IAM roles | ingest, clean, reporting (read-only) |
| S3 notification | ObjectCreated → clean Lambda |
| CloudWatch alarms | Error count > 0 → SNS |

## Key design decision
Ingest stays **outside VPC** (internet access for OWID). Clean can run inside VPC later if RDS is enabled.

## Done when
- [ ] Ingestion module files in repo
- [ ] You can explain S3 event → clean Lambda flow
- [ ] Pushed to GitHub

## AWS required?
No — code only.
