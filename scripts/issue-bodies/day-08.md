## What we are doing today

Day 8 adds **Athena SQL queries** — the analytics layer that answers your original public health question: vaccination coverage by region over time.

## Why it matters

- Shows the **end goal** of the pipeline: SQL on S3 without loading into a traditional warehouse.
- **`vaccination_by_region.sql`** — portfolio demo query.
- **`create_views.sql`** — star-schema views over Glue tables for cleaner reporting.

## Instructions

### Step 1 — Create sql folder
```bash
mkdir -p sql
```

### Step 2 — vaccination_by_region.sql
1. Create and paste from local project.
2. Read the query: groups by region, year, indicator; filters last 10 years.

### Step 3 — create_views.sql
1. Create and paste from local project.
2. Defines `vw_vaccination_summary` and `vw_who_threshold_gaps` views.

## What happens later (after AWS deploy)
1. Glue crawler registers Parquet tables in `health_lake_dev` database.
2. Open Athena console → workgroup `health-lake-dev`.
3. Run these SQL files and screenshot results for portfolio.

## Done when
- [ ] Both SQL files in `sql/`
- [ ] You understand what question each query answers
- [ ] Pushed to GitHub

## AWS required?
No — SQL files only. Run in Athena after Day 14 deploy.
