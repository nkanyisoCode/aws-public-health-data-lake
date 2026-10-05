## What we are doing today

Day 3 adds **operational documentation**: how much the project costs and what to do when something breaks. Cloud engineers are judged on cost control and runbooks, not just diagrams.

## Why it matters

- **`cost-estimate.md`** — shows you understand AWS billing (S3, Lambda, Glue, optional RDS traps).
- **`runbook.md`** — proves you can operate the system: failed ingest, failed clean, empty Athena results.

## Instructions

### Step 1 — docs/cost-estimate.md
1. Create the file and paste from local project.
2. Read the optional add-ons table — note RDS and NAT Gateway are the expensive items we deliberately avoid.
3. Keep dev defaults cheap (~$0.60/month core pipeline).

### Step 2 — docs/runbook.md
1. Create the file and paste from local project.
2. Skim the three failure scenarios: ingestion, cleaning, Athena.
3. These commands will make sense after AWS deploy; for now they document your plan.

## Done when
- [ ] Cost estimate documents monthly spend and controls
- [ ] Runbook covers ingest failure, clean failure, and empty Athena
- [ ] Both files pushed to GitHub

## AWS required?
No.
