with intermediary_table AS (SELECT 
cohort_category
, COUNT(DISTINCT customer_unique_id) as total_customer
, COUNT(DISTINCT customer_unique_id)*100/SUM(COUNT(*)) OVER() as percentage_total
 FROM `fai-data-portfolio.Olist.int_customer_behaviour`
 GROUP BY cohort_category
)
SELECT
cohort_category
, total_customer
, ROUND(percentage_total,2) as percentage_total
FROM intermediary_table