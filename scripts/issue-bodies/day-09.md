## What we are doing today

Day 9 starts **Infrastructure as Code** with the S3 **data lake module**. This Terraform code creates your bucket, security settings, lifecycle rules, and zone prefixes — the storage foundation everything else depends on.

## Why it matters

- **Repeatable infrastructure** — rebuild the entire bucket with one command.
- **Security by default** — block public access, encrypt at rest, deny non-HTTPS traffic.
- **Cost control** — lifecycle rules tier `raw/` to cheaper storage and expire `athena-results/`.

## Instructions

### Step 1 — Create module structure
```bash
mkdir -p terraform/modules/data_lake
mkdir -p terraform/envs/dev
```

### Step 2 — Add three module files
1. `terraform/modules/data_lake/variables.tf`
2. `terraform/modules/data_lake/main.tf`
3. `terraform/modules/data_lake/outputs.tf`

Paste all from local complete project.

## What the module creates
| Resource | Purpose |
|----------|---------|
| S3 data lake bucket | `{owner}-health-lake-{env}-{account_id}` |
| S3 logs bucket | Access logs + CloudTrail delivery |
| Versioning | On raw data — recover from overwrites |
| Lifecycle | raw/ → IA → Glacier; athena-results/ 7d expiry; quarantine/ 30d |
| Bucket policy | Deny insecure transport; optional VPC endpoint for curated/ |

## Optional test
```bash
terraform fmt -check terraform/modules/data_lake/
```

## Done when
- [ ] All three files in `terraform/modules/data_lake/`
- [ ] You can explain raw/clean/curated/quarantine prefixes
- [ ] Pushed to GitHub

## AWS required?
No — Terraform code only. `terraform apply` comes after dev env wiring (Day 13).
