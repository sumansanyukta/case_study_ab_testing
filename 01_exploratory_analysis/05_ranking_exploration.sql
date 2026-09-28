-- Purpose : Validate grain, profile columns and surface anomalies in the
-- 5.1 Grain check: one row per product x virtual category
-- If total_rows = total_identifying_rows, the key is unique.
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT CONCAT(CAST(product_id AS STRING), '|', CAST(virtual_category_id AS STRING))) AS total_identifying_rows,
  COUNT(DISTINCT product_id) AS distinct_products,
  COUNT(DISTINCT virtual_category_id) AS distinct_categories
FROM `about-you-case-study.1_raw.01_raw_ranking_hiring_case`;


-- 5.2 Categories: size and path
SELECT
  country_code,
  virtual_category_id,
  vcat_path,
  COUNT(*) AS products,
  SUM(kpi_impressions) AS impressions
FROM `about-you-case-study.1_raw.01_raw_ranking_hiring_case`
GROUP BY country_code, virtual_category_id, vcat_path
ORDER BY products DESC;


-- 5.3 Products listed in both categories
SELECT
  COUNT(*) AS products_in_both_categories
FROM (
  SELECT product_id
  FROM `about-you-case-study.1_raw.01_raw_ranking_hiring_case`
  GROUP BY product_id
  HAVING COUNT(DISTINCT virtual_category_id) > 1
);


-- 5.4 Status flags: share of products and share of impressions
SELECT 'is_sponsored' AS flag, CAST(is_sponsored AS STRING) AS value,
       COUNT(*) AS products, SUM(kpi_impressions) AS impressions
FROM `about-you-case-study.1_raw.01_raw_ranking_hiring_case` GROUP BY 1, 2
UNION ALL
SELECT 'is_new', CAST(is_new AS STRING), COUNT(*), SUM(kpi_impressions)
FROM `about-you-case-study.1_raw.01_raw_ranking_hiring_case` GROUP BY 1, 2
UNION ALL
SELECT 'is_topperformer_in_vcat', CAST(is_topperformer_in_vcat AS STRING), COUNT(*), SUM(kpi_impressions)
FROM `about-you-case-study.1_raw.01_raw_ranking_hiring_case` GROUP BY 1, 2
UNION ALL
SELECT 'is_merchant_prio_one', CAST(is_merchant_prio_one AS STRING), COUNT(*), SUM(kpi_impressions)
FROM `about-you-case-study.1_raw.01_raw_ranking_hiring_case` GROUP BY 1, 2
UNION ALL
SELECT 'size_availability_bucket', CAST(size_availability_bucket AS STRING), COUNT(*), SUM(kpi_impressions)
FROM `about-you-case-study.1_raw.01_raw_ranking_hiring_case` GROUP BY 1, 2
UNION ALL
SELECT 'price_cluster_group', CAST(price_cluster_group AS STRING), COUNT(*), SUM(kpi_impressions)
FROM `about-you-case-study.1_raw.01_raw_ranking_hiring_case` GROUP BY 1, 2
ORDER BY flag, value;


-- 5.5 Brands and product groups: concentration of impressions
SELECT
  brand_name,
  COUNT(*) AS products,
  SUM(kpi_impressions) AS impressions,
  ROUND(SUM(kpi_impressions) / SUM(SUM(kpi_impressions)) OVER () * 100, 2) AS pct_impressions
FROM `about-you-case-study.1_raw.01_raw_ranking_hiring_case`
GROUP BY brand_name
ORDER BY impressions DESC
LIMIT 20;


-- 5.6 Numerical ranges and nulls
SELECT
  COUNTIF(probability_click IS NULL)       AS null_prob_click,
  COUNTIF(probability_conversion IS NULL)  AS null_prob_conversion,
  COUNTIF(pc_marginal_ratio IS NULL)       AS null_margin,
  COUNTIF(return_rate IS NULL)             AS null_return_rate,
  COUNTIF(current_price IS NULL)           AS null_price,
  MIN(current_price)       AS min_price,       MAX(current_price)       AS max_price,
  MIN(total_discount)      AS min_discount,    MAX(total_discount)      AS max_discount,
  MIN(pc_marginal_ratio)   AS min_margin,      MAX(pc_marginal_ratio)   AS max_margin,
  MIN(return_rate)         AS min_return_rate, MAX(return_rate)         AS max_return_rate,
  MIN(probability_click)   AS min_prob_click,  MAX(probability_click)   AS max_prob_click,
  MIN(probability_conversion) AS min_prob_conv, MAX(probability_conversion) AS max_prob_conv
FROM `about-you-case-study.1_raw.01_raw_ranking_hiring_case`;


-- 5.7 Anomaly checks
SELECT
  COUNTIF(kpi_clicks > kpi_impressions)   AS rows_clicks_gt_impressions,
  COUNTIF(COALESCE(kpi_impressions, 0) = 0) AS rows_zero_impressions,
  COUNTIF(pc_marginal_ratio < 0)          AS rows_negative_margin,
  COUNTIF(return_rate > 1 OR return_rate < 0) AS rows_return_rate_out_of_range,
  COUNTIF(probability_click > 1 OR probability_click < 0) AS rows_prob_click_out_of_range,
  COUNTIF(current_price <= 0)             AS rows_non_positive_price,
  ROUND(SUM(IF(pc_marginal_ratio < 0, kpi_impressions, 0)) / SUM(kpi_impressions) * 100, 2) AS pct_impressions_negative_margin
FROM `about-you-case-study.1_raw.01_raw_ranking_hiring_case`;


-- 5.8 Model calibration: predicted click probability vs observed CTR by decile
SELECT
  click_prob_decile,
  ROUND(AVG(probability_click), 4) AS avg_predicted_click,
  ROUND(SAFE_DIVIDE(SUM(kpi_clicks), SUM(kpi_impressions)), 4) AS observed_ctr,
  SUM(kpi_impressions) AS impressions
FROM (
  SELECT *, NTILE(10) OVER (ORDER BY probability_click) AS click_prob_decile
  FROM `about-you-case-study.1_raw.01_raw_ranking_hiring_case`
)
GROUP BY click_prob_decile
ORDER BY click_prob_decile;
