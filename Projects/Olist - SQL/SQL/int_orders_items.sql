-- CTE (intermediary_table) : Calcul des informations agrégées par commande
WITH intermediary_table AS (
  SELECT 
    DISTINCT order_id,  -- Identifiant unique de la commande
    COUNT(order_item_id) AS total_items,  -- Nombre total d'articles dans la commande
    CASE
      WHEN COUNT(order_item_id) = 1 THEN "one-item_order"  -- Catégorie pour une commande avec un seul article
      WHEN COUNT(order_item_id) > 1 THEN "multi-items_order"  -- Catégorie pour une commande avec plusieurs articles
    END AS order_type,  
    SUM(price) AS total_price  -- Montant total de la commande
  FROM `fai-data-portfolio.Olist.stg_order_items`
  GROUP BY order_id  -- Regroupe par commande
)

-- Requête principale : Ajout des informations agrégées aux détails des commandes
SELECT 
  o.*,  
  intermediary_table.total_items AS total_items,  
  order_type,  
  total_price  
FROM `fai-data-portfolio.Olist.stg_orders` AS o
JOIN intermediary_table  -- Jointure avec la table intermédiaire sur l'ID de commande
ON o.order_id = intermediary_table.order_id;
