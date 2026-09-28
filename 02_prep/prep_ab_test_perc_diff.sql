-- prep_ab_test_perc_diff.sql
-- Purpose : One row per metric: control, treatment and relative lift.
--           Rates are computed on group totals; per-visitor metrics use
--           distinct visitors over the full period.
-- Source  : 02_prep.prep_ab_test_hiring
-- Output  : 02_prep.prep_ab_test_perc_diff (dashboard page 1)

CREATE OR REPLACE TABLE `about-you-case-study.02_prep.prep_ab_test_perc_diff` AS 
WITH Table1 AS (
SELECT
  test_group,
  COUNT(DISTINCT full_visitor_id) AS total_visitor,
  AVG(price_in_euro) AS price_in_euro,
  AVG(price_in_euro_discounted) AS price_in_euro_discounted,
  SUM(kpi_net_revenue) AS kpi_net_revenue, 
  SUM(kpi_profit) AS kpi_profit,
  SUM(sum_orders) AS sum_orders,
  COUNT(DISTINCT (CASE WHEN sum_orders > 0 THEN full_visitor_id ELSE NULL END)) AS converters,
  SUM(kpi_gross_revenue) AS kpi_gross_revenue,
  SUM(sum_first_orders) AS sum_first_orders,
  SUM(kpi_gross_sales) AS kpi_gross_sales, 
  SUM(kpi_net_sales) AS kpi_net_sales,
  SUM(kpi_click) AS kpi_click,
  SUM(kpi_impressions) AS kpi_impressions,
  SUM(kpi_add_to_baskets) AS kpi_add_to_baskets,
  SUM(bidding_events) AS bidding_events, 
  SUM(sponsored_profit) AS sponsored_profit
FROM `about-you-case-study.02_prep.prep_ab_test_hiring`
GROUP BY test_group
),

metric_per_visitor AS (
  SELECT
  test_group,
  price_in_euro AS avg_price_in_euro,
  price_in_euro_discounted AS avg_price_in_euro_discounted,
  kpi_net_revenue/total_visitor AS kpi_net_revenue_per_visitor,
  kpi_profit/total_visitor AS kpi_profit_per_visitor,
  converters/total_visitor AS conversion_rate,
  kpi_net_revenue/sum_orders AS aov,
  sum_orders/total_visitor AS order_per_visitor,
  sum_first_orders/sum_orders AS first_orders_share,
  kpi_gross_sales/sum_orders AS items_per_order,
  (kpi_gross_sales - kpi_net_sales)/sum_orders AS returned_items_per_order,
  (kpi_gross_sales - kpi_net_sales)/kpi_gross_sales AS return_rate_items,
  (kpi_gross_revenue - kpi_net_revenue)/kpi_gross_revenue AS return_rate_eur,
  kpi_click/kpi_impressions AS ctr,
  kpi_add_to_baskets/kpi_click AS add_to_basket_rate,
  sum_orders/kpi_add_to_baskets AS basket_to_order_rate,
  kpi_impressions/total_visitor AS impressions_per_visitor,
  (price_in_euro - price_in_euro_discounted)/price_in_euro AS discount_rate,
  bidding_events / total_visitor AS bidding_events_per_visitor,
  sponsored_profit/total_visitor AS sponsored_profit_per_visitor,
  SAFE_DIVIDE(sponsored_profit,CAST(bidding_events AS FLOAT64)) AS sponsored_profit_per_bid,

FROM Table1
),

side_by_side AS (
  SELECT
  MAX(CASE WHEN test_group='ph1-c' THEN kpi_profit_per_visitor ELSE NULL END) AS profit_control,
  MAX(CASE WHEN test_group='ph1-1' THEN kpi_profit_per_visitor ELSE NULL END) AS profit_treatment,
  MAX(CASE WHEN test_group='ph1-c' THEN kpi_net_revenue_per_visitor ELSE NULL END) AS net_revenue_control,
  MAX(CASE WHEN test_group='ph1-1' THEN kpi_net_revenue_per_visitor ELSE NULL END) AS net_revenue_treatment,
  MAX(CASE WHEN test_group='ph1-c' THEN conversion_rate ELSE NULL END) AS conversion_rate_control,
  MAX(CASE WHEN test_group='ph1-1' THEN conversion_rate ELSE NULL END) AS conversion_rate_treatment,
  MAX(CASE WHEN test_group='ph1-c' THEN aov ELSE NULL END) AS aov_control,
  MAX(CASE WHEN test_group='ph1-1' THEN aov ELSE NULL END) AS aov_treatment,
  MAX(CASE WHEN test_group='ph1-c' THEN order_per_visitor ELSE NULL END) AS order_per_visitor_control,
  MAX(CASE WHEN test_group='ph1-1' THEN order_per_visitor ELSE NULL END) AS order_per_visitor_treatment,
  MAX(CASE WHEN test_group='ph1-c' THEN first_orders_share ELSE NULL END) AS first_orders_control,
  MAX(CASE WHEN test_group='ph1-1' THEN first_orders_share ELSE NULL END) AS first_orders_treatment,
  MAX(CASE WHEN test_group='ph1-c' THEN items_per_order ELSE NULL END) AS items_per_order_control,
  MAX(CASE WHEN test_group='ph1-1' THEN items_per_order ELSE NULL END) AS items_per_order_treatment, 
  MAX(CASE WHEN test_group='ph1-c' THEN returned_items_per_order ELSE NULL END) AS returned_items_per_order_control,
  MAX(CASE WHEN test_group='ph1-1' THEN returned_items_per_order ELSE NULL END) AS returned_items_per_order_treatment, 
  MAX(CASE WHEN test_group='ph1-c' THEN return_rate_items ELSE NULL END) AS return_rate_items_control,
  MAX(CASE WHEN test_group='ph1-1' THEN return_rate_items ELSE NULL END) AS return_rate_items_treatment, 
  MAX(CASE WHEN test_group='ph1-c' THEN return_rate_eur ELSE NULL END) AS return_rate_eur_control,
  MAX(CASE WHEN test_group='ph1-1' THEN return_rate_eur ELSE NULL END) AS return_rate_eur_treatment,
  MAX(CASE WHEN test_group='ph1-c' THEN ctr ELSE NULL END) AS ctr_control,
  MAX(CASE WHEN test_group='ph1-1' THEN ctr ELSE NULL END) AS ctr_treatment,
  MAX(CASE WHEN test_group='ph1-c' THEN add_to_basket_rate ELSE NULL END) AS add_to_basket_rate_control,
  MAX(CASE WHEN test_group='ph1-1' THEN add_to_basket_rate ELSE NULL END) AS add_to_basket_rate_treatment,
  MAX(CASE WHEN test_group='ph1-c' THEN basket_to_order_rate ELSE NULL END) AS basket_to_order_rate_control,
  MAX(CASE WHEN test_group='ph1-1' THEN basket_to_order_rate ELSE NULL END) AS basket_to_order_rate_treatment,
  MAX(CASE WHEN test_group='ph1-c' THEN impressions_per_visitor ELSE NULL END) AS impressions_per_visitor_control,
  MAX(CASE WHEN test_group='ph1-1' THEN impressions_per_visitor ELSE NULL END) AS impressions_per_visitor_treatment,
  MAX(CASE WHEN test_group='ph1-c' THEN bidding_events_per_visitor ELSE NULL END) AS bidding_events_per_visitor_control,
  MAX(CASE WHEN test_group='ph1-1' THEN bidding_events_per_visitor ELSE NULL END) AS bidding_events_per_visitor_treatment,
  MAX(CASE WHEN test_group='ph1-c' THEN discount_rate ELSE NULL END) AS discount_rate_control,
  MAX(CASE WHEN test_group='ph1-1' THEN discount_rate ELSE NULL END) AS discount_rate_treatment,
  MAX(CASE WHEN test_group='ph1-c' THEN sponsored_profit_per_visitor ELSE NULL END) AS sponsored_profit_per_visitor_control,
  MAX(CASE WHEN test_group='ph1-1' THEN sponsored_profit_per_visitor ELSE NULL END) AS sponsored_profit_per_visitor_treatment,
  MAX(CASE WHEN test_group='ph1-c' THEN sponsored_profit_per_bid ELSE NULL END) AS sponsored_profit_per_bid_control,
  MAX(CASE WHEN test_group='ph1-1' THEN sponsored_profit_per_bid ELSE NULL END) AS sponsored_profit_per_bid_treatment,
  FROM metric_per_visitor
),

diff_calculation1 AS (
SELECT
  #profit
  profit_control,
  profit_treatment,
  #net_revenue
  net_revenue_control,
  net_revenue_treatment,
  #cost
  net_revenue_control - profit_control AS cost_control,
  net_revenue_treatment - profit_treatment AS cost_treatment,
  #conversion_rate
  conversion_rate_control,
  conversion_rate_treatment,
  #average_order_value
  aov_control,
  aov_treatment,
  #order_per_visitor
  order_per_visitor_control,
  order_per_visitor_treatment,
  #first_orders
  first_orders_control,
  first_orders_treatment,
  #items_per_order
  items_per_order_control,
  items_per_order_treatment,
  #returned_items_per_order
  returned_items_per_order_control,
  returned_items_per_order_treatment,
  #return_rate_items
  return_rate_items_control,
  return_rate_items_treatment,
  #return_rate_eur
  return_rate_eur_control,
  return_rate_eur_treatment,
  #ctr
  ctr_control,
  ctr_treatment,
  #add_to_basket_rate
  add_to_basket_rate_control,
  add_to_basket_rate_treatment,
  #basket_to_order_rate
  basket_to_order_rate_control,
  basket_to_order_rate_treatment,
  #impressions_per_visitor
  impressions_per_visitor_control,
  impressions_per_visitor_treatment,
  #bidding_events_per_visitor
  bidding_events_per_visitor_control,
  bidding_events_per_visitor_treatment,
  #discount_rate
  discount_rate_control,
  discount_rate_treatment,
  #sponsored_profit_per_visitor
  sponsored_profit_per_visitor_control,
  sponsored_profit_per_visitor_treatment,
  #sponsored_profit_per_bid
  sponsored_profit_per_bid_control,
  sponsored_profit_per_bid_treatment,
  #diff_perc
  ((profit_treatment - profit_control)/profit_control)*100 AS profit_diff_perc,
  ((net_revenue_treatment - net_revenue_control)/net_revenue_control)*100 AS net_revenue_diff_perc,
  ((conversion_rate_treatment - conversion_rate_control)/conversion_rate_control)*100 AS conversion_rate_diff_perc,
  ((aov_treatment - aov_control)/aov_control)*100 AS aov_diff_perc,
  ((order_per_visitor_treatment - order_per_visitor_control)/order_per_visitor_control)*100 AS order_per_visitor_diff_perc,
  ((first_orders_treatment - first_orders_control)/first_orders_control)*100 AS first_orders_diff_perc,
  ((items_per_order_treatment - items_per_order_control)/items_per_order_control)*100 AS items_per_order_diff_perc,
  ((returned_items_per_order_treatment - returned_items_per_order_control)/returned_items_per_order_control)*100 AS returned_items_per_order_diff_perc,
  ((return_rate_items_treatment - return_rate_items_control)/return_rate_items_control)*100 AS return_rate_items_diff_perc,
  ((return_rate_eur_treatment - return_rate_eur_control)/return_rate_eur_control)*100 AS return_rate_eur_diff_perc,
  ((ctr_treatment - ctr_control)/ctr_control) * 100 AS ctr_diff_perc,
  ((add_to_basket_rate_treatment - add_to_basket_rate_control)/add_to_basket_rate_control) * 100 AS add_to_basket_rate_diff_perc,
  ((basket_to_order_rate_treatment - basket_to_order_rate_control)/basket_to_order_rate_control) * 100 AS basket_to_order_rate_diff_perc,
  ((impressions_per_visitor_treatment - impressions_per_visitor_control)/impressions_per_visitor_control) * 100 AS impressions_per_visitor_diff_perc,
  ((bidding_events_per_visitor_treatment - bidding_events_per_visitor_control)/bidding_events_per_visitor_control) * 100 AS bidding_events_per_visitor_diff_perc,
  ((discount_rate_treatment - discount_rate_control)/discount_rate_control) * 100 AS discount_rate_diff_perc,
  ((sponsored_profit_per_visitor_treatment - sponsored_profit_per_visitor_control)/sponsored_profit_per_visitor_control) * 100 AS sponsored_profit_per_visitor_diff_perc,
  ((sponsored_profit_per_bid_treatment - sponsored_profit_per_bid_control)/sponsored_profit_per_bid_control) * 100 AS sponsored_profit_per_bid_diff_perc,
FROM side_by_side
),

diff_calculation2 AS (
  SELECT *,
  ((cost_treatment - cost_control)/cost_control)*100 AS cost_diff_perc
FROM diff_calculation1
)

SELECT
  CASE metric
    WHEN 'profit' THEN 'Profit per Visitor (€)'
    WHEN 'net_revenue' THEN 'Net Revenue per Visitor (€)'
    WHEN 'cost' THEN 'Cost per Visitor (€)'
    WHEN 'conversion_rate' THEN 'Conversion Rate'
    WHEN 'aov' THEN 'Average Order Value (€)'
    WHEN 'order_per_visitor' THEN 'Orders per Visitor'
    WHEN 'first_orders_share' THEN 'First-Order Share'
    WHEN 'items_per_order' THEN 'Items per Order'
    WHEN 'returned_items_per_order' THEN 'Returned Items per Order'
    WHEN 'return_rate_items' THEN 'Return Rate (Items)'
    WHEN 'return_rate_eur' THEN 'Return Rate (€)'
    WHEN 'ctr' THEN 'Click-Through Rate'
    WHEN 'add_to_basket_rate' THEN 'Add-to-Basket Rate'
    WHEN 'basket_to_order_rate' THEN 'Basket-to-Order Rate'
    WHEN 'impressions_per_visitor' THEN 'Impressions per Visitor'
    WHEN 'bidding_events_per_visitor' THEN 'Bidding Events per Visitor'
    WHEN 'discount_rate' THEN 'Discount Rate'
    WHEN 'sponsored_profit_per_visitor' THEN 'Sponsored Profit per Visitor (€)'
    WHEN 'sponsored_profit_per_bid' THEN 'Sponsored Profit per Bid (€)'
  END AS metric_name,
  CASE
    WHEN metric IN ('profit','net_revenue','cost') THEN 'Outcome'
    WHEN metric IN ('conversion_rate','ctr','add_to_basket_rate','basket_to_order_rate','order_per_visitor','impressions_per_visitor') THEN 'Funnel'
    WHEN metric IN ('aov','items_per_order','discount_rate') THEN 'Basket'
    WHEN metric IN ('return_rate_items','return_rate_eur','returned_items_per_order') THEN 'Returns'
    ELSE 'Sponsored & Customers'
  END AS metric_group,
  control,
  treatment,
  diff_perc / 100 AS lift
FROM diff_calculation2
UNPIVOT (
  (control, treatment, diff_perc) FOR metric IN (
    (profit_control, profit_treatment, profit_diff_perc) AS 'profit',
    (net_revenue_control, net_revenue_treatment, net_revenue_diff_perc) AS 'net_revenue',
    (cost_control, cost_treatment, cost_diff_perc) AS 'cost',
    (conversion_rate_control, conversion_rate_treatment, conversion_rate_diff_perc) AS 'conversion_rate',
    (aov_control, aov_treatment, aov_diff_perc) AS 'aov',
    (order_per_visitor_control, order_per_visitor_treatment, order_per_visitor_diff_perc) AS 'order_per_visitor',
    (first_orders_control, first_orders_treatment, first_orders_diff_perc) AS 'first_orders_share',
    (items_per_order_control, items_per_order_treatment, items_per_order_diff_perc) AS 'items_per_order',
    (returned_items_per_order_control, returned_items_per_order_treatment, returned_items_per_order_diff_perc) AS 'returned_items_per_order',
    (return_rate_items_control, return_rate_items_treatment, return_rate_items_diff_perc) AS 'return_rate_items',
    (return_rate_eur_control, return_rate_eur_treatment, return_rate_eur_diff_perc) AS 'return_rate_eur',
    (ctr_control, ctr_treatment, ctr_diff_perc) AS 'ctr',
    (add_to_basket_rate_control, add_to_basket_rate_treatment, add_to_basket_rate_diff_perc) AS 'add_to_basket_rate',
    (basket_to_order_rate_control, basket_to_order_rate_treatment, basket_to_order_rate_diff_perc) AS 'basket_to_order_rate',
    (impressions_per_visitor_control, impressions_per_visitor_treatment, impressions_per_visitor_diff_perc) AS 'impressions_per_visitor',
    (bidding_events_per_visitor_control, bidding_events_per_visitor_treatment, bidding_events_per_visitor_diff_perc) AS 'bidding_events_per_visitor',
    (discount_rate_control, discount_rate_treatment, discount_rate_diff_perc) AS 'discount_rate',
    (sponsored_profit_per_visitor_control, sponsored_profit_per_visitor_treatment, sponsored_profit_per_visitor_diff_perc) AS 'sponsored_profit_per_visitor',
    (sponsored_profit_per_bid_control, sponsored_profit_per_bid_treatment, sponsored_profit_per_bid_diff_perc) AS 'sponsored_profit_per_bid'
  )
)
