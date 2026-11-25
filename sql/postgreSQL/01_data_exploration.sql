-- =========================================
-- PROJECT: OLIST E-COMMERCE DATA ANALYSIS
-- SECTION 1: DATA EXPLORATION
-- =========================================

-- 1. Explore orders table
SELECT *
FROM raw.orders
LIMIT 10;


-- 2. Total orders and unique customer IDs
SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customer_ids
FROM raw.orders;


-- 3. Total customer records and unique customers
SELECT
    COUNT(*) AS total_customer_records,
    COUNT(DISTINCT customer_unique_id) AS actual_unique_customers
FROM raw.customers;


-- 4. Order status distribution
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM raw.orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 5. Review score distribution
SELECT
    review_score,
    COUNT(*) AS total_reviews
FROM raw.order_reviews
GROUP BY review_score
ORDER BY review_score DESC;


-- 6. Record count across all raw tables

SELECT 'customers' AS table_name, COUNT(*) AS total_records FROM raw.customers
UNION ALL
SELECT 'orders', COUNT(*) FROM raw.orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM raw.order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM raw.order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM raw.order_reviews
UNION ALL
SELECT 'products', COUNT(*) FROM raw.products
UNION ALL
SELECT 'sellers', COUNT(*) FROM raw.sellers
UNION ALL
SELECT 'geolocation', COUNT(*) FROM raw.geolocation
UNION ALL
SELECT 'product_category_name_translation', COUNT(*) FROM raw.product_category_name_translation
ORDER BY table_name;