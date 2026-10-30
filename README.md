# Public Health Data Lake on AWS

**Verification:** WTC-ZEYUKTVH

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
├── .github/workflows/     # CI/CD 
├── lambda/                # ingest + clean 
├── sql/                   # Athena queries 
└── terraform/             # IaC modules 
```

## Live demo (dev, after deploy)

Set region and bucket (from Terraform output in `terraform/envs/dev`):

```bash
export AWS_DEFAULT_REGION=af-south-1
cd aws-public-health-data-lake
BUCKET="$(terraform -chdir=terraform/envs/dev output -raw data_lake_bucket)"
INGEST_DATE="$(date +%Y-%m-%d)"

# 1) Ingest OWID CSV → S3 raw/ (triggers clean Lambda)
./scripts/manual_ingest.sh dev "$INGEST_DATE" "$BUCKET"

# 2) Show lake zones
aws s3 ls "s3://${BUCKET}/raw/owid/ingest_date=${INGEST_DATE}/"
aws s3 ls "s3://${BUCKET}/curated/" --recursive | head -10

# 3) Refresh Glue catalog (if tables are stale)
aws glue start-crawler --name health-lake-clean-dev
aws glue get-crawler --name health-lake-clean-dev \
  --query 'Crawler.[State,LastCrawl.Status]' --output text

# 4) Athena — run in console (workgroup health-lake-dev, DB health_lake_dev) or CLI:
aws athena start-query-execution \
  --work-group health-lake-dev \
  --query-execution-context Database=health_lake_dev \
  --result-configuration "OutputLocation=s3://${BUCKET}/athena-results/" \
  --query-string "SELECT d.region_name, f.year, f.indicator_name, f.value
FROM fact_health_indicator f
JOIN dim_region d ON f.region_key = d.region_key
WHERE f.indicator_code = 'measles_mcv1' AND f.year >= 2020
ORDER BY f.year DESC, d.region_name
LIMIT 10;"
```

Poll CLI queries with `aws athena get-query-execution --query-execution-id <id>`. Full troubleshooting: [`docs/runbook.md`](docs/runbook.md).

## Quick start (after full build)

See [`docs/architecture.md`](docs/architecture.md) and [`docs/runbook.md`](docs/runbook.md) for deploy and recovery steps once all issues are complete.

## Query with Athena

After deploy, ingest, clean, and a successful Glue crawl (`health-lake-clean-{env}`), query the **curated** tables (not per-indicator Glue names unless your crawler creates them).

| Setting | Dev example |
|---------|-------------|
| Region | `af-south-1` |
| Workgroup | `health-lake-dev` |
| Database | `health_lake_dev` |
| Result prefix | `s3://{data_lake_bucket}/athena-results/` |

**Console:** AWS → **Athena** → select workgroup and database → paste SQL from [`sql/vaccination_by_region.sql`](sql/vaccination_by_region.sql) or run [`sql/create_views.sql`](sql/create_views.sql) then query `vw_vaccination_summary`.

**CLI:** set `AWS_DEFAULT_REGION=af-south-1` and use `aws athena start-query-execution` with `--work-group health-lake-dev` and `--query-execution-context Database=health_lake_dev` (see [`docs/runbook.md`](docs/runbook.md)).

**Typical Glue tables after crawl:** `fact_health_indicator`, `dim_region`, and often a merged `clean` table for the `clean/` prefix. Example:

```sql
SELECT d.region_name, f.year, f.indicator_name, f.value
FROM health_lake_dev.fact_health_indicator f
JOIN health_lake_dev.dim_region d ON f.region_key = d.region_key
WHERE f.indicator_code = 'measles_mcv1' AND f.year >= 2015
ORDER BY f.year DESC, d.region_name
LIMIT 20;
```

## Cost

Core pipeline: **~$0.60/month**. See [`docs/cost-estimate.md`](docs/cost-estimate.md).

## License

Portfolio / educational use.
