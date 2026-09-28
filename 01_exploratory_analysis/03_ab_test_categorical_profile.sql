-- Purpose : Distinct values and row counts for each categorical column
-- 3.1 test_type
SELECT test_type, COUNT(*) AS row_count
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
GROUP BY test_type
ORDER BY row_count DESC;


-- 3.2 test_group
SELECT test_group, COUNT(*) AS row_count
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
GROUP BY test_group
ORDER BY row_count DESC;


-- 3.3 is_control
SELECT is_control, COUNT(*) AS row_count
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
GROUP BY is_control
ORDER BY row_count DESC;


-- 3.4 NEW: consistency check - is_control should map 1:1 to test_group
SELECT test_group, is_control, COUNT(*) AS row_count
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
GROUP BY test_group, is_control
ORDER BY test_group, is_control;


-- 3.5 multitest_visitor
SELECT multitest_visitor, COUNT(*) AS row_count
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
GROUP BY multitest_visitor
ORDER BY row_count DESC;


-- 3.6 customer_gender
SELECT customer_gender, COUNT(*) AS row_count
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
GROUP BY customer_gender
ORDER BY row_count DESC;


-- 3.7 device
SELECT device, COUNT(*) AS row_count
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
GROUP BY device
ORDER BY row_count DESC;


-- 3.8 country_code
SELECT country_code, COUNT(*) AS row_count
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
GROUP BY country_code
ORDER BY row_count DESC;


-- 3.9 country_cluster
SELECT country_cluster, COUNT(*) AS row_count
FROM `about-you-case-study.1_raw.1_raw_ab_test_hiring_case`
GROUP BY country_cluster
ORDER BY row_count DESC;
