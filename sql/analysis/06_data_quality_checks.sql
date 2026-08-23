-- Row counts
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM raw.customers
UNION ALL
SELECT 'orders', COUNT(*) FROM raw.orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM raw.order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM raw.payments
UNION ALL
SELECT 'products', COUNT(*) FROM raw.products;

-- Duplicate customer IDs
SELECT customer_id, COUNT(*)
FROM raw.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Missing customer unique IDs
SELECT COUNT(*) AS missing_customer_unique_id
FROM raw.customers
WHERE customer_unique_id IS NULL;

-- Invalid negative monetary values
SELECT COUNT(*) AS invalid_item_prices
FROM raw.order_items
WHERE price < 0;

SELECT COUNT(*) AS invalid_payment_values
FROM raw.payments
WHERE payment_value < 0;

-- Order statuses
SELECT order_status, COUNT(*) AS orders
FROM raw.orders
GROUP BY order_status
ORDER BY orders DESC;
