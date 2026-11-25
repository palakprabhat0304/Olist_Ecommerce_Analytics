
-- =========================================
-- PROJECT: OLIST E-COMMERCE DATA ANALYSIS
-- SECTION 3: DELIVERY PERFORMANCE ANALYSIS
-- =========================================


-- 1. Overall delivery performance

WITH delivery_data AS (
    SELECT
        order_id,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        CASE
            WHEN order_delivered_customer_date >
                 order_estimated_delivery_date
            THEN 'Late'
            ELSE 'On Time / Early'
        END AS delivery_status
    FROM raw.orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
)

SELECT
    COUNT(*) AS total_delivered_orders,
    COUNT(*) FILTER (
        WHERE delivery_status = 'Late'
    ) AS late_orders,
    COUNT(*) FILTER (
        WHERE delivery_status = 'On Time / Early'
    ) AS on_time_orders,
    ROUND(
        COUNT(*) FILTER (WHERE delivery_status = 'Late') * 100.0
        / COUNT(*), 2
    ) AS late_delivery_percentage
FROM delivery_data;


-- 2. Late delivery delay statistics (in days)

SELECT
    COUNT(*) AS late_orders,
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (
                order_delivered_customer_date -
                order_estimated_delivery_date
            )) / 86400
        )::numeric, 2
    ) AS average_delay_days,
    ROUND(
        (PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY EXTRACT(EPOCH FROM (
                order_delivered_customer_date -
                order_estimated_delivery_date
            )) / 86400
        ))::numeric, 2
    ) AS median_delay_days,
    ROUND(
        MAX(EXTRACT(EPOCH FROM (
            order_delivered_customer_date -
            order_estimated_delivery_date
        )) / 86400)::numeric, 2
    ) AS maximum_delay_days
FROM raw.orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_delivered_customer_date > order_estimated_delivery_date;


-- 3. Delay severity distribution

WITH late_orders AS (
    SELECT
        EXTRACT(EPOCH FROM (
            order_delivered_customer_date -
            order_estimated_delivery_date
        )) / 86400 AS delay_days
    FROM raw.orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
      AND order_delivered_customer_date > order_estimated_delivery_date
),
severity AS (
    SELECT
        CASE
            WHEN delay_days <= 3 THEN '1-3 Days'
            WHEN delay_days <= 7 THEN '4-7 Days'
            ELSE 'More than 7 Days'
        END AS delay_category
    FROM late_orders
)

SELECT
    delay_category,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM severity
GROUP BY delay_category
ORDER BY
    CASE delay_category
        WHEN '1-3 Days' THEN 1
        WHEN '4-7 Days' THEN 2
        ELSE 3
    END;


-- 4. Monthly late delivery trends
-- Orders are grouped by purchase month, not delivery month.

WITH monthly_delivery AS (
    SELECT
        DATE_TRUNC('month', order_purchase_timestamp) AS purchase_month,
        order_id,
        CASE
            WHEN order_delivered_customer_date >
                 order_estimated_delivery_date
            THEN 1
            ELSE 0
        END AS is_late
    FROM raw.orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
)

SELECT
    TO_CHAR(purchase_month, 'YYYY-MM') AS purchase_month,
    COUNT(*) AS total_orders,
    SUM(is_late) AS late_orders,
    ROUND(
        SUM(is_late) * 100.0 / COUNT(*), 2
    ) AS late_delivery_percentage
FROM monthly_delivery
GROUP BY purchase_month
ORDER BY purchase_month;


-- 5. State-wise delivery performance
-- Customer state represents the delivery destination.

WITH state_delivery AS (
    SELECT
        c.customer_state,
        o.order_id,
        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END AS is_late
    FROM raw.orders o
    JOIN raw.customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)

SELECT
    customer_state,
    COUNT(*) AS total_orders,
    SUM(is_late) AS late_orders,
    ROUND(
        SUM(is_late) * 100.0 / COUNT(*), 2
    ) AS late_delivery_percentage
FROM state_delivery
GROUP BY customer_state
HAVING COUNT(*) >= 100
ORDER BY late_delivery_percentage DESC;


-- 6. Average review rating: Late vs On-time delivery
-- One row per order before joining reviews.

WITH delivery_status AS (
    SELECT
        order_id,
        CASE
            WHEN order_delivered_customer_date >
                 order_estimated_delivery_date
            THEN 'Late Delivery'
            ELSE 'On-time / Early'
        END AS delivery_group
    FROM raw.orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
)

SELECT
    d.delivery_group,
    COUNT(DISTINCT d.order_id) AS total_orders,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM delivery_status d
JOIN raw.order_reviews r
    ON d.order_id = r.order_id
GROUP BY d.delivery_group
ORDER BY d.delivery_group;


-- 7. Review rating by delay duration

WITH delayed_orders AS (
    SELECT
        order_id,
        EXTRACT(EPOCH FROM (
            order_delivered_customer_date -
            order_estimated_delivery_date
        )) / 86400 AS delay_days
    FROM raw.orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
      AND order_delivered_customer_date > order_estimated_delivery_date
),
delay_groups AS (
    SELECT
        order_id,
        CASE
            WHEN delay_days <= 3 THEN '1-3 Days'
            WHEN delay_days <= 7 THEN '4-7 Days'
            WHEN delay_days <= 14 THEN '8-14 Days'
            ELSE 'More than 14 Days'
        END AS delay_category
    FROM delayed_orders
)

SELECT
    d.delay_category,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.review_score), 2) AS average_review_score,
    COUNT(*) FILTER (
        WHERE r.review_score = 1
    ) AS one_star_reviews,
    ROUND(
        COUNT(*) FILTER (WHERE r.review_score = 1) * 100.0
        / COUNT(r.review_id), 2
    ) AS one_star_percentage
FROM delay_groups d
JOIN raw.order_reviews r
    ON d.order_id = r.order_id
GROUP BY d.delay_category
ORDER BY
    CASE d.delay_category
        WHEN '1-3 Days' THEN 1
        WHEN '4-7 Days' THEN 2
        WHEN '8-14 Days' THEN 3
        ELSE 4
    END;
