-- CTE (_order) : Agrège les données par client et année
WITH _order AS (
  SELECT 
    customer_unique_id,
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,  -- Extrait l'année de la commande
    COUNT(order_id) AS total_order,  -- Totalise les commandes pour chaque client et année
    CASE
      WHEN COUNT(order_id) = 1 THEN "one_shot"  -- Classement des clients en fonction de leur fréquence d'achat
      ELSE "long_term"
    END AS cohort_number_order,
    MIN(order_purchase_timestamp) AS first_purchase_date,  -- Première commande
    MAX(order_purchase_timestamp) AS last_purchase_date  -- Dernière commande
  FROM `fai-data-portfolio.Olist.stg_orders` 
  GROUP BY customer_unique_id, EXTRACT(YEAR FROM order_purchase_timestamp)
  ORDER BY customer_unique_id DESC
)

-- Requête principale : Ajoute des métriques basées sur des calculs analytiques
SELECT 
  customer_unique_id,
  _order.year AS purchase_year,
  total_order,
  cohort_number_order,
  
  -- Nombre de commandes de l'année précédente pour le même client
  LAG(total_order) OVER (
    PARTITION BY customer_unique_id  -- Regroupe par client
    ORDER BY _order.year             -- Classe par année croissante pour chaque client
  ) AS previous_year_orders,
  
  -- Taux de croissance YoY : ((valeur actuelle - valeur précédente) / valeur précédente) * 100
  CASE
    WHEN LAG(total_order) OVER (PARTITION BY customer_unique_id ORDER BY _order.year) IS NOT NULL THEN
      (total_order - LAG(total_order) OVER (PARTITION BY customer_unique_id ORDER BY _order.year)) 
        * 100.0 / LAG(total_order) OVER (PARTITION BY customer_unique_id ORDER BY _order.year)
    ELSE NULL  -- Pas de taux calculable si pas de données de l'année précédente
  END AS growth_rate_yoy,
  
  first_purchase_date,
  last_purchase_date,
  
  -- Âge en jours : différence entre la première et la dernière commande
  DATE_DIFF(DATE(last_purchase_date), DATE(first_purchase_date), DAY) AS age_day

FROM _order
ORDER BY customer_unique_id, total_order DESC;
