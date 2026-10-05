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

Detailed design and security rationale live on the Wiki (not in this repo):

| Topic | Wiki page |
|-------|-----------|
| Data flow, S3 zones, bucket strategy, networking | [Architecture](https://github.com/nkanyisoCode/aws-public-health-data-lake/wiki/Architecture) |
| Encryption, IAM, audit, CI/CD auth | [Security Decisions](https://github.com/nkanyisoCode/aws-public-health-data-lake/wiki/Security-Decisions) |
| Mermaid diagrams | [Architecture Overview](https://github.com/nkanyisoCode/aws-public-health-data-lake/wiki/Architecture-Overview) |
| Monthly cost breakdown and controls | [Cost Estimate](https://github.com/nkanyisoCode/aws-public-health-data-lake/wiki/Cost-Estimate) |
| Ingest, clean, Athena failure recovery | [Runbook](https://github.com/nkanyisoCode/aws-public-health-data-lake/wiki/Runbook) |

## Wiki & planning (not in this repo)

| Resource | Link |
|----------|------|
| **Documentation & diagrams** | [GitHub Wiki](https://github.com/nkanyisoCode/aws-public-health-data-lake/wiki) |
| **14-day build plan (issues)** | [GitHub Issues](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues) |

Architecture, security, cost estimate, runbook, and UML diagrams live on the Wiki. Build tasks are tracked via GitHub Issues — keeping this repository for code only.

## AWS services

| Service | Purpose |
|---------|---------|
| S3 | Data lake (raw / clean / curated / quarantine zones) |
| Lambda + EventBridge | Scheduled ingest + event-driven clean |
| Glue + Athena | Schema catalog and SQL on Parquet |
| IAM | Least-privilege roles per pipeline stage |
| CloudWatch + SNS | Alarms and email alerts |
| Terraform | Infrastructure as Code (dev + prod) |
| GitHub Actions + OIDC | CI/CD without stored AWS keys |

## Target repository structure

Built incrementally via [GitHub Issues](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues):

```
aws-public-health-data-lake/
├── .github/workflows/     # CI/CD (Day 14)
├── lambda/                # ingest + clean (Days 5–6)
├── sql/                   # Athena queries (Day 8)
└── terraform/             # IaC modules (Days 9–14)
```

## Quick start (after full build)

See the [Wiki Architecture page](https://github.com/nkanyisoCode/aws-public-health-data-lake/wiki/Architecture) and [Runbook](https://github.com/nkanyisoCode/aws-public-health-data-lake/wiki/Runbook) for deploy steps once all issues are complete.

## Cost

Core pipeline: **~$0.60/month**. See [Wiki — Cost Estimate](https://github.com/nkanyisoCode/aws-public-health-data-lake/wiki/Cost-Estimate).

## License

Portfolio / educational use.
