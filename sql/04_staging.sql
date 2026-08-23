DROP VIEW IF EXISTS staging.orders_clean CASCADE;
DROP VIEW IF EXISTS staging.customers_clean CASCADE;
DROP VIEW IF EXISTS staging.order_items_clean CASCADE;
DROP VIEW IF EXISTS staging.payments_clean CASCADE;
DROP VIEW IF EXISTS staging.products_clean CASCADE;

CREATE VIEW staging.customers_clean AS
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    INITCAP(TRIM(customer_city)) AS customer_city,
    UPPER(TRIM(customer_state)) AS customer_state
FROM raw.customers;

CREATE VIEW staging.orders_clean AS
SELECT
    order_id,
    customer_id,
    LOWER(TRIM(order_status)) AS order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM raw.orders;

CREATE VIEW staging.order_items_clean AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
FROM raw.order_items
WHERE price >= 0 AND freight_value >= 0;

CREATE VIEW staging.payments_clean AS
SELECT
    order_id,
    payment_sequential,
    LOWER(TRIM(payment_type)) AS payment_type,
    payment_installments,
    payment_value
FROM raw.payments
WHERE payment_value >= 0;

CREATE VIEW staging.products_clean AS
SELECT
    product_id,
    COALESCE(NULLIF(TRIM(product_category_name), ''), 'unknown') AS product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM raw.products;
