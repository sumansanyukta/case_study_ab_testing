CREATE OR REPLACE TABLE `about-you-case-study.02_prep.prep_ranking_category` AS
SELECT
  virtual_category_id,
  vcat_path,
  product_id,
  brand_name,
  product_group_name,
  is_sponsored,
  is_new,
  is_topperformer_in_vcat,

  #readable dimensions
  CASE
    WHEN pc_marginal_ratio < 0    THEN '1. Negative'
    WHEN pc_marginal_ratio < 0.10 THEN '2. 0-10%'
    WHEN pc_marginal_ratio < 0.20 THEN '3. 10-20%'
    ELSE '4. 20%+'
  END AS margin_band,
  CASE size_availability_bucket
    WHEN 1 THEN '1. Low stock'
    WHEN 2 THEN '2. Limited'
    WHEN 3 THEN '3. Good'
    WHEN 4 THEN '4. Full range'
  END AS size_availability,
  price_cluster_group,
  IF(is_sponsored, 'Sponsored', 'Organic') AS placement_type,
  IF(is_new, 'New', 'Established') AS product_age,
  IF(is_topperformer_in_vcat, 'Top performer', 'Other') AS performer_type,
  IF(is_merchant_prio_one, 'Prio One', 'Not Prio') AS merchant_prio,

  #raw values: summed in Looker
  kpi_impressions AS impressions,
  kpi_clicks AS clicks,
  kpi_gross_sales AS gross_sales,
  kpi_gross_revenue AS gross_revenue,
  pc_marginal_ratio * kpi_gross_revenue AS margin_profit,
  return_rate * kpi_gross_sales AS returned_items,
  probability_click,
  probability_conversion,
  NTILE(10) OVER (ORDER BY probability_click) AS click_prob_decile
FROM `about-you-case-study.1_raw.01_raw_ranking_hiring_case`
