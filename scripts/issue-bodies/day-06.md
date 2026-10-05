## Summary
Build the Clean Lambda that transforms raw CSV into Parquet, curated tables, and quarantine rows.

## Prerequisites
- Issue #5 closed — ingest Lambda code exists

## What we are doing today
You write the core data transformation function. It reads wide-format OWID vaccination CSV, validates and standardises it, writes partitioned Parquet to `clean/`, star-schema extracts to `curated/`, and bad rows to `quarantine/`.

## Why it matters
This implements the medallion architecture step (raw → clean → curated). When wired in Terraform (Day 10), S3 `ObjectCreated` on `raw/*.csv` triggers this automatically — no manual cleaning step.

## Step-by-step instructions

### Step 1 — Create lambda/clean folder
```bash
mkdir -p lambda/clean
```

### Step 2 — lambda/clean/requirements.txt
List: `boto3`, `pandas`, `pyarrow`

### Step 3 — lambda/clean/handler.py
Implement logic that:

1. **Parse S3 event** — extract bucket and key from `Records[0]`.
2. **Read CSV** — load raw file from S3 into pandas.
3. **Reshape** — melt wide OWID format (Entity, Code, Year + indicator columns) to long format.
4. **Metadata** — map indicator columns (MCV1, DTP3, Pol3, HepB3) to codes, names, category, unit.
5. **Regions** — standardise names, ISO codes, region_type (country / aggregate / unknown), region_key.
6. **Validate** — reject rows with invalid year, missing region, or value outside 0–100%; collect reject reasons.
7. **Write clean/** — Parquet partitions at `clean/{indicator_code}/year={year}/part-0000.parquet`
8. **Write curated/** — `dim_region` and `fact_health_indicator` Parquet files.
9. **Write quarantine/** — rejected rows to `quarantine/rejected/ingest_date={date}/part-0000.parquet`
10. **Trigger crawler** — call `glue.start_crawler()` if `GLUE_CRAWLER_NAME` env var is set (ignore if already running).

Optional test: `python3 -m py_compile lambda/clean/handler.py`

## Files to create
- `lambda/clean/requirements.txt`
- `lambda/clean/handler.py`

## Done when
- [ ] Handler covers clean, curated, and quarantine output paths
- [ ] Validation separates good rows from rejected rows
- [ ] You can explain each S3 zone the function writes to
- [ ] Files pushed to `main`

## AWS required?
No — code only.
