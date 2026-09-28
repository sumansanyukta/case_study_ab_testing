-- =====================================================================
-- 07_ab_test_segmentation.sql
-- Purpose : Check whether the profit drop is broad-based or driven by one
--           segment: multitest status, country cluster, gender, day
-- Source  : about-you-case-study.02_prep.prep_ab_test_hiring (7.1 - 7.3)
--           about-you-case-study.02_prep.prep_ab_test_daily   (7.4)
-- Output  : Analysis only (no table created)
-- Note    : Visitors are counted distinct within a segment over the month.
--           Discount rate = impression-weighted share of price reduction
--           of the products SHOWN (not the products bought).
-- =====================================================================


-- 7.1 - 7.3 Segment lift. Change `segment` in the first CTE to switch:
--   7.1 multitest_visitor   7.2 country_cluster   7.3 customer_gender
WITH base AS (
  SELECT
    CAST(multitest_visitor AS STRING) AS segment,
    test_group,
    full_visitor_id,
    COALESCE(kpi_profit, 0)      AS profit,
    COALESCE(kpi_net_revenue, 0) AS net_revenue,
    COALESCE(sum_orders, 0)      AS orders,
    IF(price_in_euro IS NOT NULL AND price_in_euro_discounted IS NOT NULL,
       price_in_euro * kpi_impressions, 0)            AS price_x_impr,
    IF(price_in_euro IS NOT NULL AND price_in_euro_discounted IS NOT NULL,
       price_in_euro_discounted * kpi_impressions, 0) AS price_disc_x_impr
  FROM `about-you-case-study.02_prep.prep_ab_test_hiring`
),

by_group AS (
  SELECT
    segment,
    test_group,
    COUNT(DISTINCT full_visitor_id)                             AS visitors,
    SUM(profit) / COUNT(DISTINCT full_visitor_id)               AS profit_pv,
    SUM(net_revenue) / COUNT(DISTINCT full_visitor_id)          AS revenue_pv,
    COUNT(DISTINCT IF(orders > 0, full_visitor_id, NULL))
      / COUNT(DISTINCT full_visitor_id)                         AS conversion,
    1 - SAFE_DIVIDE(SUM(price_disc_x_impr), SUM(price_x_impr))  AS discount_rate
  FROM base
  GROUP BY segment, test_group
)

SELECT
  c.segment,
  c.visitors                                                AS visitors_control,
  t.visitors                                                AS visitors_treatment,
  ROUND((t.profit_pv  - c.profit_pv)  / c.profit_pv  * 100, 2) AS profit_change_pct,
  ROUND((t.revenue_pv - c.revenue_pv) / c.revenue_pv * 100, 2) AS revenue_change_pct,
  ROUND((t.conversion - c.conversion) / c.conversion * 100, 2) AS conversion_change_pct,
  ROUND((t.discount_rate - c.discount_rate) * 100, 2)          AS discount_rate_change_pp,
  c.visitors < 10000                                        AS small_segment_flag
FROM by_group c
JOIN by_group t
  ON c.segment = t.segment
 AND c.test_group = 'ph1-c'
 AND t.test_group = 'ph1-1'
ORDER BY visitors_control DESC;


-- 7.4 Daily stability: per visitor-day lifts, from the daily table
WITH by_day AS (
  SELECT
    date,
    test_group,
    SUM(visitors)                                                AS visitors,
    SUM(profit) / SUM(visitors)                                  AS profit_pvd,
    SUM(net_revenue) / SUM(visitors)                             AS revenue_pvd,
    1 - SAFE_DIVIDE(SUM(price_discounted_x_impressions), SUM(price_x_impressions)) AS discount_rate
  FROM `about-you-case-study.02_prep.prep_ab_test_daily`
  GROUP BY date, test_group
),

daily AS (
  SELECT
    c.date,
    c.visitors                                                   AS visitors_control,
    t.visitors                                                   AS visitors_treatment,
    (t.profit_pvd  - c.profit_pvd)  / c.profit_pvd  * 100        AS profit_change_pct,
    (t.revenue_pvd - c.revenue_pvd) / c.revenue_pvd * 100        AS revenue_change_pct,
    (t.discount_rate - c.discount_rate) * 100                    AS discount_rate_change_pp
  FROM by_day c
  JOIN by_day t
    ON c.date = t.date
   AND c.test_group = 'Control'
   AND t.test_group = 'Treatment'
)

SELECT
  COUNT(*)                              AS n_days,
  COUNTIF(profit_change_pct < 0)        AS days_profit_down,
  COUNTIF(revenue_change_pct > 0)       AS days_revenue_up,
  COUNTIF(discount_rate_change_pp > 0)  AS days_discount_up,
  MIN(visitors_control)                 AS min_daily_visitors_control,
  MAX(visitors_control)                 AS max_daily_visitors_control
FROM daily;
