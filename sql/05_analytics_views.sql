DROP VIEW IF EXISTS analytics.order_summary CASCADE;
DROP VIEW IF EXISTS analytics.customer_360 CASCADE;

CREATE VIEW analytics.order_summary AS
SELECT
    o.order_id,
    c.customer_unique_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp::date AS order_date,
    EXTRACT(YEAR FROM o.order_purchase_timestamp)::int AS order_year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp)::int AS order_month,
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS order_month_start,
    c.customer_state,
    c.customer_city,
    COALESCE(i.item_revenue, 0) AS item_revenue,
    COALESCE(i.freight_revenue, 0) AS freight_revenue,
    COALESCE(i.item_revenue, 0) + COALESCE(i.freight_revenue, 0) AS gross_order_value,
    COALESCE(p.payment_value, 0) AS payment_value
FROM staging.orders_clean o
JOIN staging.customers_clean c
    ON o.customer_id = c.customer_id
LEFT JOIN (
    SELECT
        order_id,
        SUM(price) AS item_revenue,
        SUM(freight_value) AS freight_revenue
    FROM staging.order_items_clean
    GROUP BY order_id
) i ON o.order_id = i.order_id
LEFT JOIN (
    SELECT order_id, SUM(payment_value) AS payment_value
    FROM staging.payments_clean
    GROUP BY order_id
) p ON o.order_id = p.order_id;

CREATE VIEW analytics.customer_360 AS
SELECT
    customer_unique_id,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(gross_order_value) AS total_revenue,
    AVG(gross_order_value) AS average_order_value,
    MAX(customer_state) AS customer_state,
    MAX(customer_city) AS customer_city
FROM analytics.order_summary
WHERE order_status NOT IN ('canceled', 'unavailable')
GROUP BY customer_unique_id;
