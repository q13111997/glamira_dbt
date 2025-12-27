WITH date_spine AS (
  SELECT d AS full_date
  FROM UNNEST(GENERATE_DATE_ARRAY('2010-01-01', '2035-12-31')) AS d
)
SELECT
  CAST(FORMAT_DATE('%Y%m%d', full_date) AS INT64) AS date_id,
  full_date,
  EXTRACT(DAYOFWEEK FROM full_date) AS day_of_week,
  EXTRACT(DAY FROM full_date) AS day_of_month,
  EXTRACT(DAYOFYEAR FROM full_date)  AS day_of_year,
  DATE_TRUNC(full_date, MONTH) AS year_month,
  EXTRACT(MONTH FROM full_date) AS month,
  EXTRACT(WEEK FROM full_date) AS week_of_year,
  EXTRACT(QUARTER FROM full_date) AS quarter_number,
  EXTRACT(YEAR FROM full_date) AS year,
  EXTRACT(YEAR FROM full_date) AS year_number,
  CASE WHEN EXTRACT(DAYOFWEEK FROM full_date) IN (1, 7) THEN TRUE
       ELSE FALSE END AS is_weekend
FROM date_spine
ORDER BY full_date