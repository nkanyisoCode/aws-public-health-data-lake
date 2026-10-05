# Public Health Data Lake on AWS

Cloud-native storage, security, and automation for the [public-health-etl-pipeline](https://github.com/nkanyisoCode/public-health-etl-pipeline) OWID vaccination dataset.

**Story:** build and clean data locally (data engineering) → store, secure, automate, and operate it in AWS (cloud engineering).

## Architecture

```
OWID CSV → EventBridge → Ingest Lambda → S3 raw/
                              ↓ (S3 event)
                         Clean Lambda → S3 clean/ + curated/ + quarantine/
                              ↓
                    Glue Crawler (on-demand) → Athena SQL
```

## Architecture diagrams

All UML and workflow diagrams are on the **[GitHub Wiki](https://github.com/nkanyisoCode/aws-public-health-data-lake/wiki)** (not in this repo).

## 14-day build plan

Daily tasks are tracked as GitHub Issues: https://github.com/nkanyisoCode/aws-public-health-data-lake/issues

## AWS services

| Service | Purpose |
|---------|---------|
| S3 | Data lake (raw / clean / curated / quarantine zones) |
| Lambda + EventBridge | Scheduled ingest + event-driven clean |
| Glue + Athena | Schema catalog and SQL on Parquet |
| IAM | Least-privilege roles per pipeline stage |
| CloudWatch + SNS | Alarms and email alerts |
| CloudTrail + S3 access logs | Audit |
| AWS Budgets | Cost alerts |
| Terraform | Infrastructure as Code (dev + prod) |
| GitHub Actions + OIDC | CI/CD without stored AWS keys |
| VPC + S3 endpoint | Optional private networking |
| GuardDuty + Config + checkov | Optional security scanning |

## Quick start

### Prerequisites

- AWS account with MFA on root
- AWS CLI configured (`aws configure`)
- Terraform >= 1.10
- Python 3.12+ (for local scripts)

### 1. Bootstrap remote state (one time)

```bash
./scripts/bootstrap_tf_state.sh nkanyiso af-south-1
# Update bucket name in terraform/envs/dev/backend.tf and prod/backend.tf
```

### 2. Configure variables

Edit `terraform/envs/dev/dev.tfvars`:

```hcl
owner       = "your-name"
alert_email = "you@example.com"
```

Confirm SNS subscription email after first apply.

### 3. Deploy dev

```bash
cd terraform/envs/dev
terraform init
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

Note the `data_lake_bucket` output.

### 4. Trigger ingestion

```bash
chmod +x scripts/*.sh
./scripts/manual_ingest.sh dev $(date +%Y-%m-%d) YOUR-BUCKET-NAME
```

The S3 event on `raw/` automatically invokes the clean Lambda. Check:

```bash
aws s3 ls s3://YOUR-BUCKET/clean/ --recursive
aws s3 ls s3://YOUR-BUCKET/curated/ --recursive
```

### 5. Query in Athena

Open the Athena console → workgroup `health-lake-dev` → database `health_lake_dev`.

Run [sql/vaccination_by_region.sql](sql/vaccination_by_region.sql).

## Repository structure

```
aws-public-health-data-lake/
├── .github/workflows/terraform.yml   # plan on PR, apply on merge, checkov
├── docs/                             # architecture, security, cost, runbook
├── lambda/
│   ├── ingest/                       # download OWID CSV → raw/
│   └── clean/                        # raw/ → clean/ + curated/ + quarantine/
├── scripts/                          # bootstrap, manual ingest, IAM tests
├── sql/                              # Athena queries and views
└── terraform/
    ├── modules/                      # data_lake, network, ingestion, analytics, ...
    └── envs/dev, prod/
```

## Feature flags (dev.tfvars)

| Variable | Default (dev) | Purpose |
|----------|---------------|---------|
| `enable_network` | `false` | VPC, private subnets, S3 gateway endpoint |
| `enable_rds` | `false` | PostgreSQL warehouse (~$15/mo if left on) |
| `enable_secrets_manager_endpoint` | `false` | VPC Lambda → RDS credentials without NAT |
| `enable_guardduty` | `false` | Threat detection |
| `enable_config` | `false` | Compliance rules |
| `enable_github_oidc` | `false` | GitHub Actions OIDC roles |

Enable optional features only while testing, then disable to control cost.

## Enhancements included

Beyond the base project spec:

- **S3 event-driven cleaning** — no manual step after ingest
- **On-demand Glue Crawler** — triggered by clean Lambda, not on a schedule
- **Quarantine zone** — bad rows saved to `quarantine/` for inspection
- **Bucket per environment** — dev and prod fully isolated (documented in architecture.md)
- **Separate CI plan/apply IAM roles** — read-only plan, write apply

## Prove least privilege

```bash
./scripts/test_iam_least_privilege.sh dev YOUR-ACCOUNT-ID YOUR-BUCKET-NAME
```

Screenshot the `AccessDenied` errors for your portfolio.

## CI/CD setup

1. Set `enable_github_oidc = true` and `github_repo = "your-user/aws-public-health-data-lake"`.
2. `terraform apply` to create OIDC provider and roles.
3. In GitHub repo **Settings → Secrets and variables → Actions → Variables**:
   - `AWS_PLAN_ROLE_ARN` = output `github_plan_role_arn`
   - `AWS_APPLY_ROLE_ARN` = output `github_apply_role_arn`
4. Protect `main` branch — require PR and passing checks.

## Documentation

- [Architecture diagrams (Wiki)](https://github.com/nkanyisoCode/aws-public-health-data-lake/wiki)
- [14-day issue tracker](docs/14-DAY-GITHUB-ISSUES.md)
- Architecture, security, cost, and runbook docs are added during [Issues #2–#3](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues)

## Cost

Core pipeline (no RDS, no GuardDuty/Config): **~$0.60/month**. See [docs/cost-estimate.md](docs/cost-estimate.md).

## License

Portfolio / educational use.
