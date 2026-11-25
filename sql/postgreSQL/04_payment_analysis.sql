
-- =========================================
-- PROJECT: OLIST E-COMMERCE DATA ANALYSIS
-- SECTION 4: PAYMENT ANALYSIS
-- =========================================


-- 1. Overall payment summary

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_payment_records,
    ROUND(SUM(payment_value)::numeric, 2) AS total_payment_value,
    ROUND(
        (SUM(payment_value) / COUNT(DISTINCT order_id))::numeric, 2
    ) AS average_order_value
FROM raw.order_payments;


-- 2. Payment method distribution

SELECT
    payment_type,
    COUNT(*) AS total_payment_records,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2
    ) AS payment_record_percentage
FROM raw.order_payments
GROUP BY payment_type
ORDER BY total_payment_records DESC;


-- 3. Payment method-wise revenue contribution

SELECT
    payment_type,
    COUNT(*) AS total_payment_records,
    ROUND(SUM(payment_value)::numeric, 2) AS total_payment_value,
    ROUND(AVG(payment_value)::numeric, 2) AS average_payment_record_value,
    ROUND(
        SUM(payment_value) * 100.0 / SUM(SUM(payment_value)) OVER (),
        2
    ) AS revenue_percentage
FROM raw.order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- 4. Installment distribution

WITH order_installments AS (
    SELECT
        order_id,
        MAX(payment_installments) AS installment_count
    FROM raw.order_payments
    GROUP BY order_id
)

SELECT
    installment_count,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2
    ) AS order_percentage
FROM order_installments
GROUP BY installment_count
ORDER BY installment_count;


-- 5. Average order value by installment count

WITH order_payment_summary AS (
    SELECT
        order_id,
        MAX(payment_installments) AS installment_count,
        SUM(payment_value) AS order_total
    FROM raw.order_payments
    GROUP BY order_id
)

SELECT
    installment_count,
    COUNT(*) AS total_orders,
    ROUND(AVG(order_total)::numeric, 2) AS average_order_value,
    ROUND(SUM(order_total)::numeric, 2) AS total_payment_value
FROM order_payment_summary
GROUP BY installment_count
ORDER BY installment_count;
