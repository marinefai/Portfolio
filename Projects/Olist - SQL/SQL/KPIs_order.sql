
SELECT 
COUNT(DISTINCT order_id) as count_orders
, ROUND(SUM(price),1) as total_price_value
, ROUND(SUM(price) / COUNT(DISTINCT order_id),1) as avg_order_value
, ROUND(COUNT(order_item_id)/COUNT(DISTINCT order_id),2) as avg_product_per_order
  FROM `fai-data-portfolio.Olist.stg_order_items` 
