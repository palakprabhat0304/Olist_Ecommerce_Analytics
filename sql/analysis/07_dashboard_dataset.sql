SELECT
    order_month_start,
    customer_state,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT customer_unique_id) AS customers,
    SUM(gross_order_value) AS revenue,
    AVG(gross_order_value) AS average_order_value
FROM analytics.order_summary
WHERE order_status NOT IN ('canceled', 'unavailable')
GROUP BY order_month_start, customer_state
ORDER BY order_month_start, customer_state;
