## Summary
Create the Terraform security module: SNS alerts, AWS Budget, and CloudTrail.

## Prerequisites
- Issue #11 closed — analytics Terraform module exists

## What we are doing today
You add observability, cost control, and audit logging — the operational layer that keeps the platform safe and affordable.

## Why it matters
Production systems need alerts when Lambdas fail, budget warnings before surprise bills, and CloudTrail for governance. Optional GuardDuty and Config can be enabled via feature flags.

## Step-by-step instructions

### Step 1 — Create security module folder
```bash
mkdir -p terraform/modules/security
```

### Step 2 — terraform/modules/security/variables.tf
Define: env, account_id, data lake bucket arn, logs bucket id/arn, alert_email, monthly_budget_usd, enable_guardduty, enable_config.

### Step 3 — terraform/modules/security/main.tf
Implement:
1. **SNS topic** — `health-lake-alerts-{env}` with email subscription when alert_email set.
2. **AWS Budget** — monthly limit filtered by `project=health-lake` tag; 80% alert.
3. **CloudTrail** — logs to logs bucket under `cloudtrail/`; S3 data events on data lake bucket.
4. **Logs bucket policy** — allow CloudTrail and (optionally) Config to write.
5. **Optional GuardDuty** detector when `enable_guardduty = true`.
6. **Optional AWS Config** recorder, delivery channel, and managed rules (S3 public read prohibited, encryption, SSL) when `enable_config = true`.

### Step 4 — terraform/modules/security/outputs.tf
Export: sns topic arn, cloudtrail arn.

## Files to create
- `terraform/modules/security/variables.tf`
- `terraform/modules/security/main.tf`
- `terraform/modules/security/outputs.tf`

## Done when
- [ ] SNS topic and budget alarm configured
- [ ] CloudTrail writes to logs bucket
- [ ] GuardDuty and Config are optional via variables
- [ ] Files pushed to `main`

## AWS required?
No — Terraform code only.
