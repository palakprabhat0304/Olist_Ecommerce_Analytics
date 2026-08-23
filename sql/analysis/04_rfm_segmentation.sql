-- RFM segmentation: portfolio-ready output with segment metrics.
WITH customer_metrics AS (
    SELECT
        customer_unique_id,
        MAX(order_date) AS last_order_date,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(gross_order_value) AS monetary
    FROM analytics.order_summary
    WHERE order_status NOT IN ('canceled', 'unavailable')
    GROUP BY customer_unique_id
),
snapshot AS (
    SELECT MAX(order_date) + 1 AS snapshot_date
    FROM analytics.order_summary
    WHERE order_status NOT IN ('canceled', 'unavailable')
),
rfm AS (
    SELECT cm.*, (s.snapshot_date - cm.last_order_date) AS recency
    FROM customer_metrics cm CROSS JOIN snapshot s
),
scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary) AS monetary_score
    FROM rfm
),
segmented AS (
    SELECT *,
        CASE
            WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
            WHEN recency_score >= 3 AND frequency_score >= 3 THEN 'Loyal Customers'
            WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'New / Promising'
            WHEN recency_score <= 2 AND frequency_score >= 3 THEN 'At Risk'
            WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'Lost'
            ELSE 'Needs Attention'
        END AS segment
    FROM scored
)
SELECT
    segment,
    COUNT(*) AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS customer_share_pct,
    ROUND(AVG(recency), 1) AS avg_recency_days,
    ROUND(AVG(frequency), 2) AS avg_orders,
    ROUND(AVG(monetary), 2) AS avg_customer_value,
    ROUND(SUM(monetary), 2) AS segment_revenue
FROM segmented
GROUP BY segment
ORDER BY segment_revenue DESC;

-- Customer-level detail for BI drill-down.
WITH customer_metrics AS (
    SELECT customer_unique_id, MAX(order_date) AS last_order_date,
           COUNT(DISTINCT order_id) AS frequency, SUM(gross_order_value) AS monetary
    FROM analytics.order_summary
    WHERE order_status NOT IN ('canceled', 'unavailable')
    GROUP BY customer_unique_id
), snapshot AS (
    SELECT MAX(order_date) + 1 AS snapshot_date FROM analytics.order_summary
    WHERE order_status NOT IN ('canceled', 'unavailable')
), scored AS (
    SELECT cm.*, (s.snapshot_date - cm.last_order_date) AS recency,
           NTILE(5) OVER (ORDER BY (s.snapshot_date - cm.last_order_date) DESC) AS recency_score,
           NTILE(5) OVER (ORDER BY frequency) AS frequency_score,
           NTILE(5) OVER (ORDER BY monetary) AS monetary_score
    FROM customer_metrics cm CROSS JOIN snapshot s
)
SELECT *,
    CONCAT(recency_score, frequency_score, monetary_score) AS rfm_score,
    CASE
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 3 THEN 'Loyal Customers'
        WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'New / Promising'
        WHEN recency_score <= 2 AND frequency_score >= 3 THEN 'At Risk'
        WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'Lost'
        ELSE 'Needs Attention'
    END AS segment
FROM scored;
