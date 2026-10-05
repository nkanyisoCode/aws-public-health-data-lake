## Summary
Add cost estimate and operational runbook documentation.

## Prerequisites
- Issue #2 closed — architecture and security docs exist

## What we are doing today
You document how much the project should cost and what to do when the pipeline fails. Cloud engineers are judged on cost control and operability, not just building resources.

## Why it matters
A $5 budget with lifecycle rules shows financial awareness. A runbook shows you can support the system after deploy — exactly what SRE and platform teams expect.

## Step-by-step instructions

### Step 1 — docs/cost-estimate.md
Write a table estimating monthly cost for:
1. **Core pipeline** (S3, Lambda, EventBridge, Glue crawler on-demand, Athena) — target ~$0.60/month on dev defaults.
2. **Optional add-ons** — RDS (~$12–18/mo), NAT Gateway (~$30/mo — deliberately avoided), GuardDuty, Config.
3. **Cost controls** — AWS Budget at $5, lifecycle rules (raw → IA → Glacier, athena-results expire in 7 days), feature flags to disable expensive services in dev.

### Step 2 — docs/runbook.md
Write step-by-step recovery for:
1. **Ingestion failed** — check CloudWatch logs for ingest Lambda, verify OWID URL, manual re-invoke.
2. **Cleaning failed** — check clean Lambda logs, inspect `quarantine/` prefix, re-run clean logic.
3. **Athena returns no data** — confirm Parquet in `clean/`, run Glue crawler, check workgroup and database name.
4. **Emergency destroy** — `terraform destroy` command and reminder to delete state bucket separately.

## Files to create
- `docs/cost-estimate.md`
- `docs/runbook.md`

## Done when
- [ ] Cost doc lists core vs optional spend and controls
- [ ] Runbook covers ingest, clean, and Athena failure paths
- [ ] Both files pushed to `main`

## AWS required?
No
