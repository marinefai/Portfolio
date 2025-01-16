WITH intermediary_table AS (SELECT *
, CASE
    WHEN total_order = 2 OR total_order = 3 THEN "occasional(2-3)"
    WHEN total_order >3 THEN "frequent(>3)"
  END AS purchase_frequency
, CAST(ROUND(SAFE_DIVIDE(total_order,(age_day/365)),0) AS int64) as avg_order_per_year
 FROM `fai-data-portfolio.Olist.int_customer_behaviour` 
 where cohort_category = "long_term"
)
SELECT
purchase_frequency
, SUM(total_order) as total_order
, ROUND(AVG(total_order),1) as avg_total_order
, MAX(total_order) as max_orders
, ROUND(AVG(avg_order_per_year),1) as avg_order_per_year
, MAX(age_day) as max_tenure
, ROUND(AVG(age_day),0) as avg_tenure
FROM intermediary_table
GROUP BY purchase_frequency
