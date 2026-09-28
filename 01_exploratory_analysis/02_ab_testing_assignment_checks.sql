-- Purpose : Check that each visitor (unit of randomisation) sees only one test group and that the groups are balanced

-- 2.1 Example visitor: inspect one returning visitor's full history
SELECT *
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
WHERE full_visitor_id = '916e31addaf3fa393600a2c5245b8aec'
ORDER BY date;


-- 2.2 Visitors assigned to MORE than one test group, this will be excluded in prep
SELECT
  full_visitor_id,
  COUNT(DISTINCT test_group) AS n_test_groups
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
GROUP BY full_visitor_id
HAVING COUNT(DISTINCT test_group) > 1;


-- 2.3 Visitors assigned to exactly ONE test group (clean)
SELECT
  full_visitor_id,
  COUNT(DISTINCT test_group) AS n_test_groups
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
GROUP BY full_visitor_id
HAVING COUNT(DISTINCT test_group) = 1;


-- 2.4 NEW: Summary of contamination
WITH visitor_groups AS (
  SELECT
    full_visitor_id,
    COUNT(DISTINCT test_group) AS n_test_groups
  FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
  GROUP BY full_visitor_id
)
SELECT
  COUNT(*) AS total_visitors,
  COUNTIF(n_test_groups > 1) AS multi_group_visitors,
  ROUND(COUNTIF(n_test_groups > 1) / COUNT(*) * 100, 2) AS pct_multi_group_visitors
FROM visitor_groups;


-- 2.5 NEW: Group balance after cleaning (sample ratio check)
SELECT
  test_group,
  COUNT(DISTINCT full_visitor_id) AS visitors,
  COUNT(*) AS visitor_days,
  ROUND(COUNT(DISTINCT full_visitor_id) / SUM(COUNT(DISTINCT full_visitor_id)) OVER () * 100, 2) AS pct_visitors
FROM `about-you-case-study.02_prep.prep_ab_test_hiring`
GROUP BY test_group
ORDER BY test_group;
