## Summary
Build the Ingest Lambda that downloads OWID vaccination CSV data for the S3 raw zone.

## Prerequisites
- Issue #4 closed — scripts folder exists

## What we are doing today
You write the first executable pipeline code: a Python Lambda handler that downloads public OWID vaccination coverage CSV from HTTPS and will upload it to S3 `raw/` when deployed.

## Why it matters
This proves serverless ingestion from a public data source. The function runs outside VPC (no NAT Gateway cost) and writes dated, immutable snapshots under `raw/owid/ingest_date=YYYY-MM-DD/`.

## Step-by-step instructions

### Step 1 — Create lambda/ingest folder
```bash
mkdir -p lambda/ingest
```

### Step 2 — lambda/ingest/requirements.txt
List dependencies needed at deploy time:
- `boto3` — S3 upload
- (stdlib `urllib` is used for download — no extra package needed)

### Step 3 — lambda/ingest/handler.py
Implement a handler that:
1. Reads `DATA_LAKE_BUCKET` from environment variables.
2. Accepts optional `ingest_date` from the event (default: today’s date ISO string).
3. Downloads CSV from OWID vaccination coverage URL via HTTPS with a User-Agent header.
4. Uploads to S3 key: `raw/owid/ingest_date={date}/vaccination_coverage.csv`
5. Sets `ContentType=text/csv` and server-side encryption on upload.
6. Returns JSON with bucket, key, byte count, and ingest_date.

Optional test: `python3 -m py_compile lambda/ingest/handler.py`

## Files to create
- `lambda/ingest/requirements.txt`
- `lambda/ingest/handler.py`

## Done when
- [ ] Handler downloads from OWID URL and targets correct S3 key pattern
- [ ] Requirements file lists boto3
- [ ] Code compiles without syntax errors
- [ ] Files pushed to `main`

## AWS required?
No — code only. Deployed and tested after Terraform ingestion module (Day 10).
