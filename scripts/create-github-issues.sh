#!/usr/bin/env bash
# Create 14 GitHub issues for the 2-week push plan.
# Usage: ./scripts/create-github-issues.sh
set -euo pipefail

REPO="${1:-nkanyisoCode/aws-public-health-data-lake}"

create_issue() {
  local title="$1"
  local body="$2"
  gh issue create --repo "$REPO" --title "$title" --body "$body" --label "2-week-plan"
}

# Create label if missing
gh label create "2-week-plan" --repo "$REPO" --color "0E8A16" --description "14-day portfolio push plan" 2>/dev/null || true

create_issue "Day 1: Repository foundation" "$(cat <<'EOF'
## Goal
Initialize the repo with README, gitignore, and checkov config.

## Tasks
- [ ] Add `README.md` — project overview and quick start
- [ ] Add `.gitignore` — Terraform, Python, secrets
- [ ] Add `.checkov.yml` — IaC security scan config

## Commit messages
1. `Add project README for AWS public health data lake`
2. `Add gitignore for Terraform, Python, and secrets`
3. `Add checkov configuration for Terraform security scanning`

## AWS required?
No

## Diagram
See `docs/project-workflow-diagram.md`
EOF
)"

create_issue "Day 2: Architecture documentation" "$(cat <<'EOF'
## Goal
Document system design and security decisions.

## Tasks
- [ ] Create `docs/` folder
- [ ] Add `docs/architecture.md` — data flow, S3 zones, bucket-per-env
- [ ] Add `docs/security-decisions.md` — encryption, IAM, audit

## Commit messages
1. `Add architecture documentation with data flow and bucket strategy`
2. `Add security decisions documentation`

## AWS required?
No
EOF
)"

create_issue "Day 3: Cost estimate and runbook" "$(cat <<'EOF'
## Goal
Add operational and cost documentation.

## Tasks
- [ ] Add `docs/cost-estimate.md`
- [ ] Add `docs/runbook.md` — what to do when ingestion/clean fails

## Commit messages
1. `Add monthly cost estimate and cost control notes`
2. `Add operational runbook for ingestion and cleaning failures`

## AWS required?
No
EOF
)"

create_issue "Day 4: Bootstrap scripts" "$(cat <<'EOF'
## Goal
Add scripts for Terraform state bootstrap and reference data.

## Tasks
- [ ] Create `scripts/` folder
- [ ] Add `scripts/bootstrap_tf_state.sh` (chmod +x)
- [ ] Add `scripts/region_aliases.csv`

## Commit messages
1. `Add Terraform remote state bootstrap script`
2. `Add region alias reference data for cleaning scripts`

## AWS required?
No (script runs later when AWS account exists)
EOF
)"

create_issue "Day 5: Ingest Lambda" "$(cat <<'EOF'
## Goal
Lambda function to download OWID CSV into S3 raw zone.

## Tasks
- [ ] Create `lambda/ingest/`
- [ ] Add `lambda/ingest/requirements.txt`
- [ ] Add `lambda/ingest/handler.py`

## Test
```bash
python3 -m py_compile lambda/ingest/handler.py
```

## Commit messages
1. `Add ingest Lambda Python dependencies`
2. `Add ingest Lambda to download OWID CSV into S3 raw zone`

## AWS required?
No
EOF
)"

create_issue "Day 6: Clean Lambda" "$(cat <<'EOF'
## Goal
Transform raw CSV to Parquet, curated tables, and quarantine zone.

## Tasks
- [ ] Create `lambda/clean/`
- [ ] Add `lambda/clean/requirements.txt`
- [ ] Add `lambda/clean/handler.py`

## Features
- Parquet output partitioned by indicator/year
- Curated dim_region + fact_health_indicator
- Quarantine rejected rows
- Trigger Glue crawler on completion

## Commit messages
1. `Add clean Lambda Python dependencies`
2. `Add clean Lambda with Parquet, curated tables, and quarantine`

## AWS required?
No
EOF
)"

create_issue "Day 7: Helper scripts" "$(cat <<'EOF'
## Goal
Local scripts for testing pipeline and IAM least privilege.

## Tasks
- [ ] Add `scripts/requirements.txt`
- [ ] Add `scripts/clean_s3.py`
- [ ] Add `scripts/manual_ingest.sh`
- [ ] Add `scripts/test_iam_least_privilege.sh`

## Commit messages
1. `Add local script dependencies`
2. `Add local S3 cleaning script mirroring Lambda logic`
3. `Add manual ingest helper script`
4. `Add IAM least-privilege denial test script`

## AWS required?
No (IAM test runs after deploy)
EOF
)"

create_issue "Day 8: Athena SQL queries" "$(cat <<'EOF'
## Goal
SQL queries for portfolio demonstration.

## Tasks
- [ ] Create `sql/` folder
- [ ] Add `sql/vaccination_by_region.sql`
- [ ] Add `sql/create_views.sql`

## Commit messages
1. `Add Athena query for vaccination coverage by region`
2. `Add Athena curated views for star schema reporting`

## AWS required?
No
EOF
)"

create_issue "Day 9: Terraform data lake module" "$(cat <<'EOF'
## Goal
S3 bucket module with zones, lifecycle, encryption, HTTPS policy.

## Tasks
- [ ] Create `terraform/modules/data_lake/`
- [ ] Create `terraform/envs/dev/` folder structure
- [ ] Add variables.tf, main.tf, outputs.tf

## Commit messages
1. `Add data lake module variables`
2. `Add S3 data lake module with raw, clean, curated zones and lifecycle rules`
3. `Add data lake module outputs`

## AWS required?
No
EOF
)"

create_issue "Day 10: Terraform ingestion module" "$(cat <<'EOF'
## Goal
Ingest Lambda, EventBridge schedule, S3 event → clean Lambda, IAM roles.

## Tasks
- [ ] Create `terraform/modules/ingestion/`
- [ ] Add variables.tf, main.tf, outputs.tf

## Key feature
S3 `ObjectCreated` on `raw/*.csv` triggers clean Lambda automatically.

## Commit messages
1. `Add ingestion module variables`
2. `Add ingestion module with scheduled ingest and S3-triggered clean pipeline`
3. `Add ingestion module outputs`

## AWS required?
No
EOF
)"

create_issue "Day 11: Terraform analytics module" "$(cat <<'EOF'
## Goal
Glue Data Catalog, on-demand crawler, Athena workgroup with scan limits.

## Tasks
- [ ] Create `terraform/modules/analytics/`
- [ ] Add variables.tf, main.tf, outputs.tf

## Key feature
Glue crawler has no schedule — clean Lambda starts it after writing Parquet.

## Commit message
`Add analytics module with on-demand Glue crawler and Athena workgroup`

## AWS required?
No
EOF
)"

create_issue "Day 12: Terraform security module" "$(cat <<'EOF'
## Goal
SNS alerts, AWS Budget, CloudTrail, optional GuardDuty and Config.

## Tasks
- [ ] Create `terraform/modules/security/`
- [ ] Add variables.tf, main.tf, outputs.tf

## Commit message
`Add security module with SNS, budget alerts, and CloudTrail`

## AWS required?
No
EOF
)"

create_issue "Day 13: Dev environment and optional network" "$(cat <<'EOF'
## Goal
Wire all modules in dev; add optional VPC and RDS modules.

## Tasks
- [ ] Add `terraform/envs/dev/backend.tf`
- [ ] Add `terraform/envs/dev/variables.tf` and `dev.tfvars`
- [ ] Add `terraform/envs/dev/main.tf`
- [ ] Add `terraform/modules/network/` (VPC, S3 endpoint, Secrets Manager endpoint)
- [ ] Add `terraform/modules/warehouse/` (optional RDS)

## Test
```bash
cd terraform/envs/dev && terraform init -backend=false && terraform validate
```

## Commit messages
1. `Add dev Terraform backend configuration`
2. `Add dev environment variables and tfvars`
3. `Add dev environment wiring all core Terraform modules`
4. `Add optional network and RDS warehouse modules`

## AWS required?
No for code; backend.tf bucket name filled when AWS ready
EOF
)"

create_issue "Day 14: CI/CD, prod environment, final polish" "$(cat <<'EOF'
## Goal
GitHub Actions, prod env, final README polish.

## Tasks
- [ ] Add `terraform/modules/cicd/` — GitHub OIDC plan/apply roles
- [ ] Add `.github/workflows/terraform.yml` — checkov + plan/apply
- [ ] Add `terraform/envs/prod/` — backend, variables, tfvars, main.tf
- [ ] Polish README.md

## Commit messages
1. `Add GitHub Actions OIDC CI/CD Terraform module`
2. `Add GitHub Actions workflow with checkov and Terraform plan/apply`
3. `Add prod environment with stricter defaults`
4. `Polish README with full project overview and deployment notes`

## After this issue
- [ ] Create AWS account
- [ ] Run bootstrap_tf_state.sh
- [ ] terraform apply
- [ ] Run Athena query and IAM denial test

## AWS required?
After Day 14 code is complete
EOF
)"

echo "Done. View issues: https://github.com/${REPO}/issues"
