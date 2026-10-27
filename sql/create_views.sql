-- Curated star-schema views over Glue tables (run in Athena after crawler SUCCEEDS).
-- Prerequisites: workgroup health-lake-dev, database health_lake_dev,
-- tables fact_health_indicator and dim_region (from s3://.../curated/).

CREATE OR REPLACE VIEW health_lake_dev.vw_vaccination_summary AS
SELECT
    f.region_key,
    d.region_name,
    d.region_type,
    f.year,
    f.indicator_code,
    f.indicator_name,
    f.indicator_category,
    f.value,
    f.is_missing,
    f.is_estimated
FROM health_lake_dev.fact_health_indicator f
LEFT JOIN health_lake_dev.dim_region d
    ON f.region_key = d.region_key
WHERE f.indicator_category = 'vaccination';

CREATE OR REPLACE VIEW health_lake_dev.vw_who_threshold_gaps AS
SELECT
    region_name,
    year,
    indicator_name,
    value AS coverage_pct,
    CASE WHEN value < 90 THEN 'below_who_threshold' ELSE 'meets_threshold' END AS status
FROM health_lake_dev.vw_vaccination_summary
WHERE region_type = 'country'
  AND value IS NOT NULL;
