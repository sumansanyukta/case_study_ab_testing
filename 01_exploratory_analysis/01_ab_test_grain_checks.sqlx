-- Primary key check
-- If total_rows = total_identifying_rows, then visitor x date x test_group is unique.
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT CONCAT(full_visitor_id, '|', CAST(date AS STRING), '|', test_group)) AS total_identifying_rows
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`;


-- Visitor x date combinations with more than one row
-- Rows returned here = visitors who appear in more than one test group on the same day.
SELECT
  date,
  full_visitor_id,
  COUNT(*) AS row_count
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
GROUP BY date, full_visitor_id
HAVING COUNT(*) > 1
ORDER BY date, full_visitor_id;


-- Visitors appearing on more than one row (returning visitors across days)
SELECT
  full_visitor_id,
  COUNT(*) AS row_count
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
GROUP BY full_visitor_id
HAVING COUNT(*) > 1
ORDER BY row_count DESC;
