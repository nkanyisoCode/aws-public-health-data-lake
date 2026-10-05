# Architecture

## Overview

This project extends the [public-health-etl-pipeline](https://github.com/nkanyisoCode/public-health-etl-pipeline) data engineering work by moving storage, scheduling, security, and monitoring into AWS. Public OWID vaccination data flows through a medallion-style S3 data lake and is queryable with Athena.

## Data flow

```
OWID CSV (public HTTPS)
        |
        v
EventBridge (weekly schedule)
        |
        v
Ingest Lambda (no VPC)  -----> CloudWatch alarm -> SNS email on failure
        |
        v
S3 raw/owid/ingest_date=YYYY-MM-DD/*.csv
        |
        |  S3 ObjectCreated event (automatic — no manual step)
        v
Clean Lambda (optional VPC) -----> quarantine/ for bad rows
        |
        +--> S3 clean/{indicator}/year=YYYY/*.parquet
        +--> S3 curated/dim_region/, fact_health_indicator/
        |
        v
Glue Crawler (on-demand, triggered by clean Lambda)
        |
        v
Glue Data Catalog -> Athena SQL
```

## S3 layout

```
s3://{owner}-health-lake-{env}-{account_id}/
  raw/owid/ingest_date=2026-10-05/vaccination_coverage.csv
  clean/measles_mcv1/year=2025/part-0000.parquet
  curated/dim_region/part-0000.parquet
  curated/fact_health_indicator/part-0000.parquet
  quarantine/rejected/ingest_date=2026-10-05/part-0000.parquet
  athena-results/          # auto-expire after 7 days
```

## Bucket strategy: one bucket per environment (with prefixes)

| Approach | This project | Tradeoff |
|----------|--------------|----------|
| **One bucket, zone prefixes** (`raw/`, `clean/`, `curated/`) | Used in early tutorials | Simple, cheap, one lifecycle policy |
| **One bucket per environment** (dev vs prod) | **Chosen here** | Isolation, separate IAM/state, independent destroy |
| **One bucket per zone** | Enterprise pattern | Maximum isolation, more policy overhead |

We use **one bucket per environment** (`nkanyiso-health-lake-dev-123456789012` vs `...-prod-...`) with **zone prefixes inside each bucket**. Dev and prod never share a bucket or Terraform state file.

## Networking (optional, `enable_network = true`)

```
                    Internet
                        |
            +-----------+-----------+
            |                       |
     Ingest Lambda            VPC 10.0.0.0/16
     (public, no VPC)         private subnets (2 AZs)
                                    |
                    +---------------+---------------+
                    |               |               |
              Clean Lambda     S3 Gateway EP    RDS PostgreSQL
              (in VPC)         (free)           (private, :5432)
                    |
              Secrets Manager
              Interface EP (optional, hourly cost)
```

- **Ingest Lambda** stays outside the VPC so it can download public CSVs without a NAT Gateway.
- **Clean Lambda** can run in private subnets when RDS is enabled.
- **S3 Gateway Endpoint** keeps S3 traffic on the AWS network (no NAT cost).
- **Secrets Manager interface endpoint** is optional (`enable_secrets_manager_endpoint`) — enable only while testing VPC Lambda + RDS; disable to save ~$7/month per AZ.

When networking is enabled, a bucket policy condition on `aws:sourceVpce` restricts reads of `curated/*` to traffic through the VPC endpoint.

## Terraform module layout

```
terraform/
  modules/
    data_lake/    # S3 buckets, lifecycle, encryption, bucket policy
    network/      # VPC, subnets, S3 + Secrets Manager endpoints, SGs
    ingestion/    # Ingest + clean Lambdas, EventBridge, S3 notifications
    analytics/    # Glue catalog, on-demand crawler, Athena workgroup
    warehouse/    # Optional RDS PostgreSQL
    security/     # SNS, Budget, CloudTrail, GuardDuty, Config
    cicd/         # GitHub OIDC roles (plan read-only, apply PowerUser)
  envs/
    dev/          # Minimal cost defaults
    prod/         # Stricter settings, networking on by default
```

## Enhancements over the base spec

These address common gaps in starter data-lake projects:

1. **S3 event-driven cleaning** — new files in `raw/` automatically invoke the clean Lambda (no polling).
2. **On-demand Glue Crawler** — no crawler schedule; clean Lambda calls `StartCrawler` after writing Parquet.
3. **Quarantine zone** — rejected rows land in `quarantine/` with 30-day expiry instead of being silently dropped.
4. **Separate GitHub OIDC plan/apply roles** — plan is read-only; apply has write access.
5. **Documented bucket-per-env decision** — see table above.

## Diagrams

UML and Mermaid diagrams live on the [GitHub Wiki](https://github.com/nkanyisoCode/aws-public-health-data-lake/wiki/Architecture-Overview) (not duplicated here).
