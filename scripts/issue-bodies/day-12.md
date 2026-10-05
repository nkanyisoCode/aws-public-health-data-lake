## What we are doing today

Day 12 adds the **security and operations module** — monitoring, alerts, audit logging, and cost controls. This is what makes the project "healthcare-grade" even on public data.

## Why it matters

- **SNS + email** — you know immediately when ingestion or cleaning fails.
- **AWS Budget** — alert at 80% of monthly limit before surprise bills.
- **CloudTrail + S3 access logs** — audit who touched the data lake.
- **Optional GuardDuty + Config** — threat detection and compliance rules (enable only for demo, then disable to save cost).

## Instructions

### Step 1 — Create module folder
```bash
mkdir -p terraform/modules/security
```

### Step 2 — Add module files
Paste `variables.tf`, `main.tf`, `outputs.tf` from local project.

## What the module creates
| Resource | Purpose |
|----------|---------|
| SNS topic | Alert destination |
| SNS email subscription | Confirm via email after first apply |
| AWS Budget | Filtered by project=health-lake tag |
| CloudTrail | Management + S3 data events on data lake |
| GuardDuty (optional) | Threat detection |
| AWS Config (optional) | S3 encryption, no public read rules |

## After deploy
Check your email and **confirm SNS subscription** or alerts will not arrive.

## Done when
- [ ] Security module files in repo
- [ ] You know which features default to off in dev (GuardDuty, Config)
- [ ] Pushed to GitHub

## AWS required?
No — code only.
