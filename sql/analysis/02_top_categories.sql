SELECT
    p.product_category_name,
    ROUND(SUM(i.price), 2) AS product_revenue,
    COUNT(DISTINCT i.order_id) AS orders,
    SUM(i.order_item_id * 0 + 1) AS units
FROM staging.order_items_clean i
JOIN staging.products_clean p
    ON i.product_id = p.product_id
JOIN staging.orders_clean o
    ON i.order_id = o.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY p.product_category_name
ORDER BY product_revenue DESC
LIMIT 10;
