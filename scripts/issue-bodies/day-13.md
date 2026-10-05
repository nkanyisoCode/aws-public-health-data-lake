## Summary
Wire all modules in the dev environment and add optional VPC and RDS modules.

## Prerequisites
- Issues #9–#12 closed — all core Terraform modules exist

## What we are doing today
You create `terraform/envs/dev/` that connects data_lake, ingestion, analytics, and security modules. You also add optional network (VPC, S3 endpoint) and warehouse (RDS) modules — disabled by default to save cost.

## Why it matters
Environment wiring is how modules become a deployable stack. Separate dev tfvars with cheap defaults (`enable_network = false`, `enable_rds = false`) keeps student accounts safe.

## Step-by-step instructions

### Step 1 — terraform/envs/dev/backend.tf
Configure S3 remote backend with placeholder bucket name, key `health-lake/dev/terraform.tfstate`, region, encrypt, use_lockfile. Require Terraform >= 1.10 and AWS provider ~> 5.0.

### Step 2 — terraform/envs/dev/variables.tf and dev.tfvars
Define variables: region, env, owner, alert_email, feature flags (network, rds, guardduty, config, github_oidc), ingest schedule, athena scan limit.

In `dev.tfvars` set your owner name, alert email, and keep expensive features off.

### Step 3 — terraform/envs/dev/main.tf
Wire modules:
- data_lake → security → analytics → ingestion
- Optional network and warehouse modules when flags enabled
- Provider default tags: project, env, owner, managed_by, cost_center
- Outputs: bucket name, lambda names, glue database, sns arn

### Step 4 — terraform/modules/network/ (optional)
Implement: VPC 10.0.0.0/16, two private subnets, S3 gateway endpoint, optional Secrets Manager interface endpoint, app and db security groups, db subnet group.

### Step 5 — terraform/modules/warehouse/ (optional)
Implement: RDS PostgreSQL, encrypted, private, manage_master_user_password via Secrets Manager, skip_final_snapshot in dev.

Validate: `cd terraform/envs/dev && terraform init -backend=false && terraform validate`

## Files to create
- `terraform/envs/dev/backend.tf`
- `terraform/envs/dev/variables.tf`
- `terraform/envs/dev/dev.tfvars`
- `terraform/envs/dev/main.tf`
- `terraform/modules/network/variables.tf`
- `terraform/modules/network/main.tf`
- `terraform/modules/network/outputs.tf`
- `terraform/modules/warehouse/variables.tf`
- `terraform/modules/warehouse/main.tf`
- `terraform/modules/warehouse/outputs.tf`

## Done when
- [ ] `terraform validate` passes in dev env
- [ ] dev.tfvars has owner and email set
- [ ] Network and RDS modules exist but default to disabled
- [ ] Files pushed to `main`

## AWS required?
No for code. Fill backend bucket name when AWS account is ready.
