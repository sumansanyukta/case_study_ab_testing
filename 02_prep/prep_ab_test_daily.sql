-- prep_ab_test_daily.sql
-- Purpose : Daily experiment table by group and segment. Visitors = visitor-days
--           (additive across dates and filters). Prices weighted by impressions.
-- Source  : 02_prep.prep_ab_test_hiring
-- Output  : 02_prep.prep_ab_test_daily (daily charts and filters, pages 1 and 3)

CREATE OR REPLACE TABLE `about-you-case-study.02_prep.prep_ab_test_daily` AS
SELECT
  date,
  CASE WHEN test_group = 'ph1-c' THEN 'Control' ELSE 'Treatment' END AS test_group,
  device,
  customer_gender,
  country_cluster,
  multitest_visitor,

  #visitor-days: additive across dates and filters
  COUNT(DISTINCT full_visitor_id) AS visitors,
  COUNT(DISTINCT IF(sum_orders > 0, full_visitor_id, NULL)) AS converters,

  SUM(kpi_profit) AS profit,
  SUM(kpi_net_revenue) AS net_revenue,
  SUM(kpi_gross_revenue) AS gross_revenue,
  SUM(kpi_gross_sales) AS gross_sales,
  SUM(kpi_net_sales) AS net_sales,
  SUM(sum_orders) AS orders,
  SUM(sum_first_orders) AS first_orders,
  SUM(kpi_impressions) AS impressions,
  SUM(kpi_click) AS clicks,
  SUM(kpi_add_to_baskets) AS add_to_baskets,
  SUM(bidding_events) AS bidding_events,
  SUM(sponsored_profit) AS sponsored_profit,
    SUM(IF(price_in_euro IS NOT NULL AND price_in_euro_discounted IS NOT NULL,
         price_in_euro * kpi_impressions, 0)) AS price_x_impressions,
  SUM(IF(price_in_euro IS NOT NULL AND price_in_euro_discounted IS NOT NULL,
         price_in_euro_discounted * kpi_impressions, 0)) AS price_discounted_x_impressions,
  
FROM `about-you-case-study.02_prep.prep_ab_test_hiring`
GROUP BY 1, 2, 3, 4, 5, 6
