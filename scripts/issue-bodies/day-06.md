## What we are doing today

Day 6 builds the **Clean Lambda** — the heart of the data pipeline. When a new CSV lands in `raw/`, this function transforms it into analytics-ready Parquet, builds curated star-schema tables, and quarantines bad rows.

## Why it matters

- Implements the **medallion architecture** step: raw CSV → clean Parquet → curated reporting tables.
- **S3 event-driven** (wired in Terraform Day 10) — no manual cleaning step after ingest.
- **Quarantine zone** — rejected rows are saved for inspection, not silently dropped.

## Instructions

### Step 1 — Create lambda/clean folder
```bash
mkdir -p lambda/clean
```

### Step 2 — requirements.txt
1. Create `lambda/clean/requirements.txt` — pandas, pyarrow, boto3.

### Step 3 — handler.py
1. Create `lambda/clean/handler.py` and paste from local project.
2. Optional test: `python3 -m py_compile lambda/clean/handler.py`

## What the code does
1. Triggered by S3 `ObjectCreated` on `raw/*.csv`.
2. Reads wide OWID CSV → melts to long format.
3. Applies indicator metadata (MCV1, DTP3, Pol3, HepB3).
4. Validates rows (year, region, value 0–100%).
5. Writes Parquet to `clean/{indicator}/year={year}/`.
6. Writes `curated/dim_region` and `curated/fact_health_indicator`.
7. Sends bad rows to `quarantine/rejected/`.
8. Calls Glue crawler (on-demand) when deployed.

## Done when
- [ ] Clean Lambda code in `lambda/clean/`
- [ ] You can explain each output zone (clean, curated, quarantine)
- [ ] Pushed to GitHub

## AWS required?
No — code only.
