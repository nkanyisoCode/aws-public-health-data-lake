## What we are doing today

Day 5 builds the **Ingest Lambda** — the first executable code in the pipeline. This function downloads public OWID vaccination CSV data and will eventually write it to S3 `raw/` zone on a weekly schedule.

## Why it matters

- Proves you can build **serverless ingestion** from a public HTTPS source.
- Runs **outside VPC** on purpose — no NAT Gateway cost to reach the internet.
- Output lands in `raw/owid/ingest_date=YYYY-MM-DD/` — immutable dated snapshots.

## Instructions

### Step 1 — Create lambda/ingest folder
```bash
mkdir -p lambda/ingest
```

### Step 2 — requirements.txt
1. Create `lambda/ingest/requirements.txt`
2. Paste from local project (boto3 for S3 upload when deployed).

### Step 3 — handler.py
1. Create `lambda/ingest/handler.py`
2. Paste from local project.
3. Read the flow: download CSV from OWID URL → `put_object` to S3 raw prefix.
4. Optional test: `python3 -m py_compile lambda/ingest/handler.py`

## What the code does
1. EventBridge (later) or manual invoke passes optional `ingest_date`.
2. Lambda downloads OWID vaccination coverage CSV.
3. Writes to `raw/owid/ingest_date={date}/vaccination_coverage.csv` with SSE encryption.

## Done when
- [ ] `lambda/ingest/handler.py` and `requirements.txt` in repo
- [ ] Code compiles without syntax errors
- [ ] Pushed to GitHub

## AWS required?
No — code only. Deployed and tested after Terraform ingestion module (Day 10).
