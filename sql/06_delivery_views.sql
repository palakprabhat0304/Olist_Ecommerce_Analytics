-- sql/06_delivery_views.sql
CREATE OR REPLACE VIEW analytics.delivery_orders AS
SELECT o.order_id, c.customer_state,
       EXTRACT(EPOCH FROM (o.order_delivered_customer_date
                         - o.order_estimated_delivery_date)) / 86400 AS delay_days,
       (o.order_delivered_customer_date > o.order_estimated_delivery_date) AS is_late
FROM raw.orders o JOIN raw.customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL;
-- sql/analysis/12_late_rate_by_state.sql
SELECT customer_state, COUNT(*) AS delivered_orders,
       SUM(is_late::int) AS late_orders,
       ROUND(100.0 * AVG(is_late::int), 2) AS late_rate_pct
FROM analytics.delivery_orders
GROUP BY customer_state HAVING COUNT(*) >= 100
ORDER BY late_rate_pct DESC;
-- sql/analysis/13_late_vs_rating.sql
SELECT CASE WHEN d.is_late THEN 'Late' ELSE 'On-time or Early' END AS delivery,
       COUNT(*) AS reviews, ROUND(AVG(r.review_score), 2) AS avg_score,
       ROUND(100.0 * AVG((r.review_score = 1)::int), 2) AS one_star_pct
FROM analytics.delivery_orders d JOIN raw.order_reviews r USING (order_id)
GROUP BY 1;
