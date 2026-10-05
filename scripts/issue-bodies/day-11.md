## What we are doing today

Day 11 adds the **analytics module** — Glue Data Catalog and Athena so you can run SQL directly on S3 Parquet files without a database server.

## Why it matters

- **Glue Crawler** discovers schema from Parquet in `clean/` and `curated/`.
- **On-demand crawler** — no schedule; Clean Lambda starts it after each run (saves cost vs hourly crawl).
- **Athena workgroup** — enforces query scan limits to prevent expensive mistakes.

## Instructions

### Step 1 — Create module folder
```bash
mkdir -p terraform/modules/analytics
```

### Step 2 — Add module files
Paste `variables.tf`, `main.tf`, `outputs.tf` from local project.

## What the module creates
| Resource | Purpose |
|----------|---------|
| Glue database | `health_lake_{env}` |
| Glue crawler | Scans clean/ + curated/ (schedule = empty) |
| Athena workgroup | `health-lake-{env}`, results → s3://.../athena-results/ |
| Scan limit | Default 1 GB per query in dev |

## How it connects
Clean Lambda writes Parquet → calls `StartCrawler` → Glue registers tables → Athena queries from Day 8 SQL files work.

## Done when
- [ ] Analytics module files in repo
- [ ] You understand on-demand vs scheduled crawler
- [ ] Pushed to GitHub

## AWS required?
No — code only.
