SELECT
    customer_state,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT customer_unique_id) AS customers,
    ROUND(SUM(gross_order_value), 2) AS revenue,
    ROUND(AVG(gross_order_value), 2) AS average_order_value
FROM analytics.order_summary
WHERE order_status NOT IN ('canceled', 'unavailable')
GROUP BY customer_state
ORDER BY average_order_value DESC;
