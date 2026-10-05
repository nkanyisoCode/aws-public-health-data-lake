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

## Documentation

Design docs live in this repo (versioned with code). UML and Mermaid diagrams live on the [GitHub Wiki](https://github.com/nkanyisoCode/aws-public-health-data-lake/wiki).

| Topic | Location |
|-------|----------|
| Data flow, S3 zones, bucket strategy, networking | [`docs/architecture.md`](docs/architecture.md) |
| Encryption, IAM, audit, CI/CD auth | [`docs/security-decisions.md`](docs/security-decisions.md) |
| Monthly cost breakdown and controls | [`docs/cost-estimate.md`](docs/cost-estimate.md) |
| Ingest, clean, Athena failure recovery | [`docs/runbook.md`](docs/runbook.md) |
| Mermaid workflow diagrams | [Wiki — Architecture Overview](https://github.com/nkanyisoCode/aws-public-health-data-lake/wiki/Architecture-Overview) |
| UML diagrams (use case, sequence, deployment, …) | [GitHub Wiki — Diagrams](https://github.com/nkanyisoCode/aws-public-health-data-lake/wiki) |

## Planning

| Resource | Link |
|----------|------|
| **14-day build plan (issues)** | [GitHub Issues](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues) |

Build tasks are tracked via GitHub Issues. AWS deploy comes after all code is on GitHub.

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

## Repository structure

Built incrementally via [GitHub Issues](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues):

```
aws-public-health-data-lake/
├── docs/                  # architecture, security, cost, runbook (Days 2–3)
├── .github/workflows/     # CI/CD (Day 14)
├── lambda/                # ingest + clean (Days 5–6)
├── sql/                   # Athena queries (Day 8)
└── terraform/             # IaC modules (Days 9–14)
```

## Quick start (after full build)

See [`docs/architecture.md`](docs/architecture.md) and [`docs/runbook.md`](docs/runbook.md) for deploy and recovery steps once all issues are complete.

## Cost

Core pipeline: **~$0.60/month**. See [`docs/cost-estimate.md`](docs/cost-estimate.md).

## License

Portfolio / educational use.
