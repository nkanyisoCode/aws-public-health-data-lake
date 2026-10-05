## Summary
Write Athena SQL queries for vaccination coverage analysis and reporting views.

## Prerequisites
- Issue #7 closed — helper scripts exist

## What we are doing today
You create SQL files that answer the portfolio question: vaccination coverage by region over time. These run in Athena after Glue registers tables (post-deploy).

## Why it matters
The data lake exists to be queried. SQL files in the repo document your analytics layer and give reviewers a concrete question the pipeline answers.

## Step-by-step instructions

### Step 1 — Create sql folder
```bash
mkdir -p sql
```

### Step 2 — sql/vaccination_by_region.sql
Write a query that:
1. Selects region_name, year, indicator_name, and average vaccination rate.
2. Filters to the last 10 years and non-null values.
3. Groups by region, year, and indicator.
4. Orders by region and year.
5. Add a comment noting the Athena workgroup and Glue database name (e.g. `health_lake_dev`).

### Step 3 — sql/create_views.sql
Write SQL to create views:
1. `vw_vaccination_summary` — joins fact and dimension columns for vaccination indicators.
2. `vw_who_threshold_gaps` — flags countries below 90% coverage threshold.

Use `CREATE OR REPLACE VIEW` syntax appropriate for Athena.

## Files to create
- `sql/vaccination_by_region.sql`
- `sql/create_views.sql`

## Done when
- [ ] Vaccination query answers the core portfolio question
- [ ] View definitions reference curated star-schema tables
- [ ] Files pushed to `main`

## AWS required?
No — SQL files only. Run in Athena after deploy.
