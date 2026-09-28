-- prep_ab_test_hiring.sql
-- Purpose : Clean A/B table: removes 230 visitors assigned to both groups,
--           adds visit_day_id (visitor x day key)
-- Source  : 1_raw.1_raw_ab_test_hiring_case
-- Output  : 02_prep.prep_ab_test_hiring (dashboard pages 1 and 3)

CREATE TABLE `about-you-case-study.02_prep.prep_ab_test_hiring` AS

WITH Table1 AS (
SELECT 
  *,
  CONCAT(full_visitor_id,'-',CAST(date AS STRING)) AS visit_day_id
 FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case` 
WHERE full_visitor_id NOT IN (
  SELECT
  full_visitor_id,
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
GROUP BY full_visitor_id
HAVING COUNT(DISTINCT test_group)>1
))

SELECT *
FROM Table1
