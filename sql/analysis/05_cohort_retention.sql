-- Cohort retention with cohort size, active customers, retention %, and revenue.
WITH customer_orders AS (
    SELECT DISTINCT customer_unique_id, order_id, order_date,
        DATE_TRUNC('month', MIN(order_date) OVER (PARTITION BY customer_unique_id))::date AS cohort_month,
        DATE_TRUNC('month', order_date)::date AS order_month,
        gross_order_value
    FROM analytics.order_summary
    WHERE order_status NOT IN ('canceled', 'unavailable')
),
cohort_counts AS (
    SELECT cohort_month, order_month,
        COUNT(DISTINCT customer_unique_id) AS active_customers,
        SUM(gross_order_value) AS cohort_revenue,
        (EXTRACT(YEAR FROM order_month) * 12 + EXTRACT(MONTH FROM order_month)
         - EXTRACT(YEAR FROM cohort_month) * 12 - EXTRACT(MONTH FROM cohort_month))::int AS month_number
    FROM customer_orders
    GROUP BY cohort_month, order_month
),
cohort_sizes AS (
    SELECT cohort_month,
        MAX(active_customers) FILTER (WHERE month_number = 0) AS cohort_size
    FROM cohort_counts GROUP BY cohort_month
)
SELECT cc.cohort_month, cc.order_month, cc.month_number,
       cc.active_customers, cs.cohort_size,
       ROUND(100.0 * cc.active_customers / NULLIF(cs.cohort_size, 0), 2) AS retention_pct,
       ROUND(cc.cohort_revenue, 2) AS cohort_revenue
FROM cohort_counts cc JOIN cohort_sizes cs USING (cohort_month)
ORDER BY cc.cohort_month, cc.month_number;
