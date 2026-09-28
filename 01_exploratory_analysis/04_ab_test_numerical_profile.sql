-- Purpose : Daily and per-group totals of numerical KPIs (trend + sanity check)

-- 4.1 Daily totals (spikes, gaps, weekly pattern)
SELECT
  date,
  AVG(price_in_euro)             AS avg_price_in_euro,
  AVG(price_in_euro_discounted)  AS avg_price_in_euro_discounted,
  SUM(kpi_impressions)           AS kpi_impressions_total,
  SUM(kpi_click)                 AS kpi_click_total,
  SUM(kpi_add_to_baskets)        AS kpi_add_to_baskets_total,
  SUM(kpi_gross_sales)           AS kpi_gross_sales_total,
  SUM(kpi_net_sales)             AS kpi_net_sales_total,
  SUM(kpi_gross_sale_reductions) AS kpi_gross_sale_reductions_total,
  SUM(kpi_gross_revenue)         AS kpi_gross_revenue_total,
  SUM(kpi_net_revenue)           AS kpi_net_revenue_total,
  SUM(kpi_profit)                AS kpi_profit_total,
  SUM(sum_orders)                AS sum_orders_total,
  SUM(sum_first_orders)          AS sum_first_orders_total,
  SUM(bidding_events)            AS bidding_events_total,
  SUM(sponsored_profit)          AS sponsored_profit_total
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
GROUP BY date
ORDER BY date;


-- 4.2 Totals per test group (whole period)
SELECT
  test_group,
  AVG(price_in_euro)             AS avg_price_in_euro,
  AVG(price_in_euro_discounted)  AS avg_price_in_euro_discounted,
  SUM(kpi_impressions)           AS kpi_impressions_total,
  SUM(kpi_click)                 AS kpi_click_total,
  SUM(kpi_add_to_baskets)        AS kpi_add_to_baskets_total,
  SUM(kpi_gross_sales)           AS kpi_gross_sales_total,
  SUM(kpi_net_sales)             AS kpi_net_sales_total,
  SUM(kpi_gross_sale_reductions) AS kpi_gross_sale_reductions_total,
  SUM(kpi_gross_revenue)         AS kpi_gross_revenue_total,
  SUM(kpi_net_revenue)           AS kpi_net_revenue_total,
  SUM(kpi_profit)                AS kpi_profit_total,
  SUM(sum_orders)                AS sum_orders_total,
  SUM(sum_first_orders)          AS sum_first_orders_total,
  SUM(bidding_events)            AS bidding_events_total,
  SUM(sponsored_profit)          AS sponsored_profit_total
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
GROUP BY test_group
ORDER BY test_group;


-- 4.3 NEW: Range and data-quality check (negatives, nulls, extremes)
SELECT
  COUNTIF(kpi_profit < 0)        AS rows_negative_profit,
  COUNTIF(kpi_net_revenue < 0)   AS rows_negative_net_revenue,
  COUNTIF(kpi_profit IS NULL)    AS rows_null_profit,
  COUNTIF(kpi_click > kpi_impressions) AS rows_clicks_gt_impressions,
  MIN(kpi_profit)                AS min_profit,
  MAX(kpi_profit)                AS max_profit,
  APPROX_QUANTILES(kpi_profit, 100)[OFFSET(99)] AS p99_profit,
  MIN(date)                      AS first_date,
  MAX(date)                      AS last_date,
  COUNT(DISTINCT date)           AS n_days
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`;

-- 4.4 -- 4.4 Null-profit check: is NULL profit the same as "no purchase"?
-- If null_profit_with_commercial_activity = 0, NULL profit can be treated as 0.
SELECT
  COUNTIF(kpi_profit IS NULL) AS null_profit_rows,

  COUNTIF(
    kpi_profit IS NULL
    AND (
      COALESCE(kpi_gross_revenue, 0) != 0
      OR COALESCE(kpi_net_revenue, 0) != 0
      OR COALESCE(sum_orders, 0) != 0
    )
  ) AS null_profit_with_commercial_activity,

  COUNTIF(
    kpi_profit IS NULL
    AND COALESCE(kpi_gross_revenue, 0) = 0
    AND COALESCE(kpi_net_revenue, 0) = 0
    AND COALESCE(sum_orders, 0) = 0
  ) AS null_profit_without_commercial_activity,

  COUNTIF(kpi_profit IS NOT NULL) AS non_null_profit_rows
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`;
