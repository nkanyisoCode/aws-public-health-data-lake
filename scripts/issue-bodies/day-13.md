## What we are doing today

Day 13 **wires everything together** in the dev environment and adds optional networking/RDS modules. This is the first day all Terraform modules connect into one deployable stack.

## Why it matters

- **`terraform/envs/dev/main.tf`** — calls data_lake, ingestion, analytics, security modules together.
- **`dev.tfvars`** — feature flags keep cost low (network/RDS off by default).
- **Network module (optional)** — VPC, private subnets, S3 gateway endpoint, Secrets Manager endpoint for RDS.
- **Warehouse module (optional)** — private RDS PostgreSQL if you need a traditional warehouse.

## Instructions

### Step 1 — Dev environment files
1. `terraform/envs/dev/backend.tf` — remote state config (update bucket name when AWS ready)
2. `terraform/envs/dev/variables.tf`
3. `terraform/envs/dev/dev.tfvars` — set your `owner` and `alert_email`
4. `terraform/envs/dev/main.tf` — wires all modules

### Step 2 — Optional modules
1. `terraform/modules/network/` — VPC, endpoints, security groups
2. `terraform/modules/warehouse/` — RDS PostgreSQL

Paste all from local project.

### Step 3 — Validate locally (no AWS needed)
```bash
cd terraform/envs/dev
terraform init -backend=false
terraform validate
```

## Feature flags in dev.tfvars (keep cheap)
| Flag | Dev default | Why |
|------|-------------|-----|
| enable_network | false | Skip VPC until needed |
| enable_rds | false | RDS ~$15/mo if left on |
| enable_guardduty | false | Save cost |
| enable_config | false | Save cost |

## Done when
- [ ] Dev env files complete
- [ ] `terraform validate` passes
- [ ] Pushed to GitHub

## AWS required?
No for validate. `terraform apply` after Day 14 when account is ready.
