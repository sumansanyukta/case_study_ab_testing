-- =====================================================================
-- 06_ab_test_significance.sql
-- Purpose : Test whether the treatment vs control differences are larger
--           than random noise (Welch z-test, 95% confidence interval)
-- Source  : about-you-case-study.02_prep.prep_ab_test_hiring
-- Output  : Analysis only (no table created)
-- Method  : Unit = visitor (the unit of randomisation). Each visitor's KPIs are
--           summed over the month; NULL profit = no purchase = 0.
--           With ~460k visitors per group, the normal approximation is valid:
--           |z| > 1.96  <=>  significant at 5%  <=>  95% CI excludes 0.
-- =====================================================================


-- 6.1 Continuous metrics: profit, net revenue, cost, orders per visitor
WITH visitor AS (
  SELECT
    full_visitor_id,
    test_group,
    SUM(COALESCE(kpi_profit, 0))      AS profit,
    SUM(COALESCE(kpi_net_revenue, 0)) AS net_revenue,
    SUM(COALESCE(kpi_net_revenue, 0)) - SUM(COALESCE(kpi_profit, 0)) AS cost,
    SUM(COALESCE(CAST(sum_orders AS FLOAT64), 0))      AS orders
  FROM `about-you-case-study.02_prep.prep_ab_test_hiring`
  GROUP BY full_visitor_id, test_group
),

long AS (
  SELECT test_group, metric, value
  FROM visitor
  UNPIVOT (value FOR metric IN (profit, net_revenue, cost, orders))
),

stats AS (
  SELECT
    metric,
    COUNTIF(test_group = 'ph1-c')                               AS n_c,
    COUNTIF(test_group = 'ph1-1')                               AS n_t,
    AVG(IF(test_group = 'ph1-c', value, NULL))                  AS mean_c,
    AVG(IF(test_group = 'ph1-1', value, NULL))                  AS mean_t,
    VAR_SAMP(IF(test_group = 'ph1-c', value, NULL))             AS var_c,
    VAR_SAMP(IF(test_group = 'ph1-1', value, NULL))             AS var_t
  FROM long
  GROUP BY metric
)

SELECT
  metric,
  n_c,
  n_t,
  ROUND(mean_c, 4)                                   AS control,
  ROUND(mean_t, 4)                                   AS treatment,
  ROUND(mean_t - mean_c, 4)                          AS abs_diff,
  ROUND((mean_t - mean_c) / mean_c * 100, 2)         AS lift_pct,
  ROUND((mean_t - mean_c) / SQRT(var_c / n_c + var_t / n_t), 2) AS z_score,
  ROUND((mean_t - mean_c) - 1.96 * SQRT(var_c / n_c + var_t / n_t), 4) AS ci95_low,
  ROUND((mean_t - mean_c) + 1.96 * SQRT(var_c / n_c + var_t / n_t), 4) AS ci95_high,
  ABS((mean_t - mean_c) / SQRT(var_c / n_c + var_t / n_t)) > 1.96      AS significant_5pct
FROM stats
ORDER BY metric;


-- 6.2 Conversion rate: two-proportion z-test (converter = at least one order in August)
WITH visitor AS (
  SELECT
    full_visitor_id,
    test_group,
    IF(SUM(COALESCE(sum_orders, 0)) > 0, 1, 0) AS converted
  FROM `about-you-case-study.02_prep.prep_ab_test_hiring`
  GROUP BY full_visitor_id, test_group
),

stats AS (
  SELECT
    COUNTIF(test_group = 'ph1-c')                AS n_c,
    COUNTIF(test_group = 'ph1-1')                AS n_t,
    AVG(IF(test_group = 'ph1-c', converted, NULL)) AS p_c,
    AVG(IF(test_group = 'ph1-1', converted, NULL)) AS p_t
  FROM visitor
)

SELECT
  n_c,
  n_t,
  ROUND(p_c * 100, 3)                                AS conv_control_pct,
  ROUND(p_t * 100, 3)                                AS conv_treatment_pct,
  ROUND((p_t - p_c) * 100, 3)                        AS diff_pp,
  ROUND((p_t - p_c) / p_c * 100, 2)                  AS lift_pct,
  ROUND((p_t - p_c) / SQRT(p_c * (1 - p_c) / n_c + p_t * (1 - p_t) / n_t), 2) AS z_score,
  ROUND(((p_t - p_c) - 1.96 * SQRT(p_c * (1 - p_c) / n_c + p_t * (1 - p_t) / n_t)) * 100, 3) AS ci95_low_pp,
  ROUND(((p_t - p_c) + 1.96 * SQRT(p_c * (1 - p_c) / n_c + p_t * (1 - p_t) / n_t)) * 100, 3) AS ci95_high_pp
FROM stats;
