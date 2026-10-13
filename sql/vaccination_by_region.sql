-- Vaccination coverage by region over the last 10 years (original portfolio question).
-- Run in Athena workgroup: health-lake-dev (or health-lake-prod)
-- Database: health_lake_dev

SELECT
    region_name,
    year,
    indicator_name,
    AVG(value) AS avg_vaccination_rate
FROM health_lake_dev.measles_mcv1
WHERE year BETWEEN year(current_date) - 10 AND year(current_date)
  AND value IS NOT NULL
GROUP BY region_name, year, indicator_name
ORDER BY region_name, year;
