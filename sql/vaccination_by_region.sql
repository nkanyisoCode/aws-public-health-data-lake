-- Vaccination coverage by region over the last 10 years (original portfolio question).
-- Run in Athena workgroup: health-lake-dev (or health-lake-prod)
-- Database: health_lake_dev
--
-- Glue crawler registers curated star-schema tables (fact_health_indicator, dim_region).
-- The merged Glue table "clean" is optional; prefer fact + dim for reporting.

SELECT
    d.region_name,
    f.year,
    f.indicator_name,
    AVG(f.value) AS avg_vaccination_rate
FROM health_lake_dev.fact_health_indicator f
INNER JOIN health_lake_dev.dim_region d
    ON f.region_key = d.region_key
WHERE f.indicator_code = 'measles_mcv1'
  AND f.year BETWEEN year(current_date) - 10 AND year(current_date)
  AND f.value IS NOT NULL
GROUP BY d.region_name, f.year, f.indicator_name
ORDER BY d.region_name, f.year;
