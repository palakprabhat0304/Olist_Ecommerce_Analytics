
CREATE TABLE raw.customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city TEXT,
    customer_state VARCHAR(2)
);

CREATE TABLE raw.orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE raw.order_items (
    order_id VARCHAR(50),
    order_item_id INTEGER,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(12,2),
    freight_value NUMERIC(12,2)
);

CREATE TABLE raw.order_payments (
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type VARCHAR(50),
    payment_installments INTEGER,
    payment_value NUMERIC(12,2)
);

CREATE TABLE raw.order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

CREATE TABLE raw.products (
    product_id VARCHAR(50),
    product_category_name TEXT,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

CREATE TABLE raw.sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix VARCHAR(10),
    seller_city TEXT,
    seller_state VARCHAR(2)
);

CREATE TABLE raw.geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat NUMERIC(12,8),
    geolocation_lng NUMERIC(12,8),
    geolocation_city TEXT,
    geolocation_state VARCHAR(2)
);

CREATE TABLE raw.product_category_name_translation (
    product_category_name TEXT,
    product_category_name_english TEXT
);

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'raw'
ORDER BY table_name;
SELECT COUNT(*) FROM raw.customers;
SELECT COUNT(*)
FROM raw.orders;

SELECT 'customers' AS table_name, COUNT(*) AS total_rows
FROM raw.customers

UNION ALL

SELECT 'orders', COUNT(*)
FROM raw.orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM raw.order_items

UNION ALL

SELECT 'order_payments', COUNT(*)
FROM raw.order_payments

UNION ALL

SELECT 'order_reviews', COUNT(*)
FROM raw.order_reviews

UNION ALL

SELECT 'products', COUNT(*)
FROM raw.products

UNION ALL

SELECT 'sellers', COUNT(*)
FROM raw.sellers

UNION ALL

SELECT 'geolocation', COUNT(*)
FROM raw.geolocation

UNION ALL

SELECT 'product_category_name_translation', COUNT(*)
FROM raw.product_category_name_translation;

SELECT *
FROM raw.orders
LIMIT 10;

SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customer_ids
FROM raw.orders;

SELECT
    COUNT(*) AS total_customer_records,
    COUNT(DISTINCT customer_unique_id) AS actual_unique_customers
FROM raw.customers;

SELECT COUNT(*) AS repeat_customers
FROM (
    SELECT customer_unique_id
    FROM raw.customers
    GROUP BY customer_unique_id
    HAVING COUNT(*) > 1
) AS repeat_buyers;

SELECT
    COUNT(DISTINCT customer_unique_id) AS total_customers,
    COUNT(DISTINCT CASE
        WHEN customer_unique_id IN (
            SELECT customer_unique_id
            FROM raw.customers
            GROUP BY customer_unique_id
            HAVING COUNT(*) > 1
        )
        THEN customer_unique_id
    END) AS repeat_customers
FROM raw.customers;

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM raw.orders
GROUP BY order_status
ORDER BY total_orders DESC;

SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM raw.orders),
        2
    ) AS percentage
FROM raw.orders
GROUP BY order_status
ORDER BY total_orders DESC;

SELECT
    review_score,
    COUNT(*) AS total_reviews
FROM raw.order_reviews
GROUP BY review_score
ORDER BY review_score DESC;


SELECT
    ROUND(AVG(review_score), 2) AS average_rating,
    COUNT(*) AS total_reviews,
    COUNT(CASE WHEN review_score >= 4 THEN 1 END) AS positive_reviews,
    COUNT(CASE WHEN review_score <= 2 THEN 1 END) AS negative_reviews
FROM raw.order_reviews;

SELECT
    COUNT(*) AS total_one_star_reviews,
    COUNT(review_comment_message) AS reviews_with_comments,
    COUNT(*) - COUNT(review_comment_message)
        AS reviews_without_comments
FROM raw.order_reviews
WHERE review_score = 1;

SELECT
    review_score,
    review_comment_message
FROM raw.order_reviews
WHERE review_score = 1
AND review_comment_message IS NOT NULL
LIMIT 20;

SELECT
    CASE
        WHEN LOWER(review_comment_message) LIKE '%entrega%'
          OR LOWER(review_comment_message) LIKE '%chegar%'
          OR LOWER(review_comment_message) LIKE '%recebi%'
        THEN 'Delivery Issues'

        WHEN LOWER(review_comment_message) LIKE '%quebrad%'
          OR LOWER(review_comment_message) LIKE '%funciona%'
        THEN 'Product Quality'

        WHEN LOWER(review_comment_message) LIKE '%faltou%'
          OR LOWER(review_comment_message) LIKE '%falta%'
        THEN 'Missing Items'

        WHEN LOWER(review_comment_message) LIKE '%reembolso%'
        THEN 'Refund Issues'

        ELSE 'Other Complaints'
    END AS complaint_category,

    COUNT(*) AS total_complaints

FROM raw.order_reviews

WHERE review_score = 1
AND review_comment_message IS NOT NULL

GROUP BY complaint_category
ORDER BY total_complaints DESC;


SELECT
    review_comment_message
FROM raw.order_reviews
WHERE review_score = 1
AND review_comment_message IS NOT NULL

AND NOT (
    LOWER(review_comment_message) LIKE '%entrega%'
    OR LOWER(review_comment_message) LIKE '%chegar%'
    OR LOWER(review_comment_message) LIKE '%recebi%'
    OR LOWER(review_comment_message) LIKE '%quebrad%'
    OR LOWER(review_comment_message) LIKE '%funciona%'
    OR LOWER(review_comment_message) LIKE '%faltou%'
    OR LOWER(review_comment_message) LIKE '%falta%'
    OR LOWER(review_comment_message) LIKE '%reembolso%'
)

LIMIT 20;

SELECT
    CASE
        WHEN LOWER(review_comment_message) LIKE '%entrega%'
          OR LOWER(review_comment_message) LIKE '%chegar%'
          OR LOWER(review_comment_message) LIKE '%prazo%'
          OR LOWER(review_comment_message) LIKE '%atras%'
          OR LOWER(review_comment_message) LIKE '%correios%'
          OR LOWER(review_comment_message) LIKE '%rastreio%'
        THEN 'Delivery Issues'

        WHEN LOWER(review_comment_message) LIKE '%faltou%'
          OR LOWER(review_comment_message) LIKE '%falta%'
          OR LOWER(review_comment_message) LIKE '%não veio%'
          OR LOWER(review_comment_message) LIKE '%nao veio%'
          OR LOWER(review_comment_message) LIKE '%apenas uma%'
        THEN 'Missing Items'

        WHEN LOWER(review_comment_message) LIKE '%enviaram%'
          OR LOWER(review_comment_message) LIKE '%não serviu%'
          OR LOWER(review_comment_message) LIKE '%nao serviu%'
          OR LOWER(review_comment_message) LIKE '%diferente%'
          OR LOWER(review_comment_message) LIKE '%especificações%'
        THEN 'Wrong or Mismatched Product'

        WHEN LOWER(review_comment_message) LIKE '%defeito%'
          OR LOWER(review_comment_message) LIKE '%qualidade%'
          OR LOWER(review_comment_message) LIKE '%material%'
          OR LOWER(review_comment_message) LIKE '%acabamento%'
          OR LOWER(review_comment_message) LIKE '%inferior%'
        THEN 'Product Quality'

        WHEN LOWER(review_comment_message) LIKE '%cancelar%'
          OR LOWER(review_comment_message) LIKE '%devolver%'
          OR LOWER(review_comment_message) LIKE '%reembolso%'
          OR LOWER(review_comment_message) LIKE '%resposta%'
        THEN 'Cancellation and Support'

        ELSE 'General Dissatisfaction'
    END AS complaint_category,

    COUNT(*) AS total_complaints

FROM raw.order_reviews

WHERE review_score = 1
AND review_comment_message IS NOT NULL

GROUP BY complaint_category
ORDER BY total_complaints DESC;

SELECT
    review_comment_message
FROM raw.order_reviews
WHERE review_score = 1
AND review_comment_message IS NOT NULL
AND LOWER(review_comment_message) NOT LIKE '%entrega%'
AND LOWER(review_comment_message) NOT LIKE '%chegar%'
AND LOWER(review_comment_message) NOT LIKE '%prazo%'
AND LOWER(review_comment_message) NOT LIKE '%atras%'
AND LOWER(review_comment_message) NOT LIKE '%correios%'
AND LOWER(review_comment_message) NOT LIKE '%rastreio%'
AND LOWER(review_comment_message) NOT LIKE '%faltou%'
AND LOWER(review_comment_message) NOT LIKE '%falta%'
AND LOWER(review_comment_message) NOT LIKE '%não veio%'
AND LOWER(review_comment_message) NOT LIKE '%nao veio%'
AND LOWER(review_comment_message) NOT LIKE '%apenas uma%'
AND LOWER(review_comment_message) NOT LIKE '%defeito%'
AND LOWER(review_comment_message) NOT LIKE '%qualidade%'
AND LOWER(review_comment_message) NOT LIKE '%material%'
AND LOWER(review_comment_message) NOT LIKE '%acabamento%'
AND LOWER(review_comment_message) NOT LIKE '%inferior%'
AND LOWER(review_comment_message) NOT LIKE '%cancelar%'
AND LOWER(review_comment_message) NOT LIKE '%devolver%'
AND LOWER(review_comment_message) NOT LIKE '%reembolso%'
AND LOWER(review_comment_message) NOT LIKE '%resposta%'
AND LOWER(review_comment_message) NOT LIKE '%enviaram%'
AND LOWER(review_comment_message) NOT LIKE '%não serviu%'
AND LOWER(review_comment_message) NOT LIKE '%nao serviu%'
AND LOWER(review_comment_message) NOT LIKE '%diferente%'
AND LOWER(review_comment_message) NOT LIKE '%especificações%'
LIMIT 30;

SELECT
    CASE
        WHEN LOWER(review_comment_message) LIKE '%não recebi%'
          OR LOWER(review_comment_message) LIKE '%nao recebi%'
          OR LOWER(review_comment_message) LIKE '%entrega%'
          OR LOWER(review_comment_message) LIKE '%chegar%'
          OR LOWER(review_comment_message) LIKE '%prazo%'
          OR LOWER(review_comment_message) LIKE '%atras%'
          OR LOWER(review_comment_message) LIKE '%correios%'
          OR LOWER(review_comment_message) LIKE '%rastreio%'
          OR LOWER(review_comment_message) LIKE '%entregue%'
        THEN 'Delivery Issues'

        WHEN LOWER(review_comment_message) LIKE '%faltou%'
          OR LOWER(review_comment_message) LIKE '%falta%'
          OR LOWER(review_comment_message) LIKE '%não veio%'
          OR LOWER(review_comment_message) LIKE '%nao veio%'
          OR LOWER(review_comment_message) LIKE '%apenas um%'
          OR LOWER(review_comment_message) LIKE '%somente um%'
          OR LOWER(review_comment_message) LIKE '%dois produtos%'
        THEN 'Missing Items'

        WHEN LOWER(review_comment_message) LIKE '%não funciona%'
          OR LOWER(review_comment_message) LIKE '%nao funciona%'
          OR LOWER(review_comment_message) LIKE '%defeito%'
          OR LOWER(review_comment_message) LIKE '%quebrou%'
          OR LOWER(review_comment_message) LIKE '%quebrado%'
          OR LOWER(review_comment_message) LIKE '%amassado%'
          OR LOWER(review_comment_message) LIKE '%erro%'
          OR LOWER(review_comment_message) LIKE '%qualidade%'
        THEN 'Product Quality or Damage'

        WHEN LOWER(review_comment_message) LIKE '%nota fiscal%'
        THEN 'Invoice Issues'

        WHEN LOWER(review_comment_message) LIKE '%cancelar%'
          OR LOWER(review_comment_message) LIKE '%devolver%'
          OR LOWER(review_comment_message) LIKE '%reembolso%'
          OR LOWER(review_comment_message) LIKE '%pós venda%'
          OR LOWER(review_comment_message) LIKE '%pos venda%'
          OR LOWER(review_comment_message) LIKE '%resposta%'
          OR LOWER(review_comment_message) LIKE '%email%'
        THEN 'Customer Support and Returns'

        WHEN LOWER(review_comment_message) LIKE '%diferente%'
          OR LOWER(review_comment_message) LIKE '%não gostei%'
          OR LOWER(review_comment_message) LIKE '%nao gostei%'
          OR LOWER(review_comment_message) LIKE '%foto%'
          OR LOWER(review_comment_message) LIKE '%descrição%'
          OR LOWER(review_comment_message) LIKE '%descricao%'
        THEN 'Product Mismatch'

        ELSE 'General Dissatisfaction'
    END AS complaint_category,

    COUNT(*) AS total_complaints

FROM raw.order_reviews
WHERE review_score = 1
AND review_comment_message IS NOT NULL

GROUP BY complaint_category
ORDER BY total_complaints DESC;

SELECT
    review_comment_message
FROM raw.order_reviews
WHERE review_score = 1
AND review_comment_message IS NOT NULL
AND (
    LOWER(review_comment_message) LIKE '%não recebi%'
    OR LOWER(review_comment_message) LIKE '%nao recebi%'
    OR LOWER(review_comment_message) LIKE '%entrega%'
    OR LOWER(review_comment_message) LIKE '%atras%'
    OR LOWER(review_comment_message) LIKE '%rastreio%'
    OR LOWER(review_comment_message) LIKE '%entregue%'
)
LIMIT 30;

SELECT
    CASE
        WHEN LOWER(review_comment_message) LIKE '%não recebi%'
          OR LOWER(review_comment_message) LIKE '%nao recebi%'
          OR LOWER(review_comment_message) LIKE '%entrega%'
          OR LOWER(review_comment_message) LIKE '%chegar%'
          OR LOWER(review_comment_message) LIKE '%prazo%'
          OR LOWER(review_comment_message) LIKE '%atras%'
          OR LOWER(review_comment_message) LIKE '%correios%'
          OR LOWER(review_comment_message) LIKE '%rastreio%'
          OR LOWER(review_comment_message) LIKE '%entregue%'
        THEN 'Delivery Issues'

        WHEN LOWER(review_comment_message) LIKE '%faltou%'
          OR LOWER(review_comment_message) LIKE '%falta%'
          OR LOWER(review_comment_message) LIKE '%não veio%'
          OR LOWER(review_comment_message) LIKE '%nao veio%'
          OR LOWER(review_comment_message) LIKE '%apenas um%'
          OR LOWER(review_comment_message) LIKE '%somente um%'
          OR LOWER(review_comment_message) LIKE '%dois produtos%'
        THEN 'Missing Items'

        WHEN LOWER(review_comment_message) LIKE '%não funciona%'
          OR LOWER(review_comment_message) LIKE '%nao funciona%'
          OR LOWER(review_comment_message) LIKE '%defeito%'
          OR LOWER(review_comment_message) LIKE '%quebrou%'
          OR LOWER(review_comment_message) LIKE '%quebrado%'
          OR LOWER(review_comment_message) LIKE '%amassado%'
          OR LOWER(review_comment_message) LIKE '%erro%'
          OR LOWER(review_comment_message) LIKE '%qualidade%'
        THEN 'Product Quality or Damage'

        WHEN LOWER(review_comment_message) LIKE '%nota fiscal%'
        THEN 'Invoice Issues'

        WHEN LOWER(review_comment_message) LIKE '%cancelar%'
          OR LOWER(review_comment_message) LIKE '%devolver%'
          OR LOWER(review_comment_message) LIKE '%reembolso%'
          OR LOWER(review_comment_message) LIKE '%pós venda%'
          OR LOWER(review_comment_message) LIKE '%pos venda%'
          OR LOWER(review_comment_message) LIKE '%resposta%'
          OR LOWER(review_comment_message) LIKE '%email%'
        THEN 'Customer Support and Returns'

        WHEN LOWER(review_comment_message) LIKE '%diferente%'
          OR LOWER(review_comment_message) LIKE '%não gostei%'
          OR LOWER(review_comment_message) LIKE '%nao gostei%'
          OR LOWER(review_comment_message) LIKE '%foto%'
          OR LOWER(review_comment_message) LIKE '%descrição%'
          OR LOWER(review_comment_message) LIKE '%descricao%'
        THEN 'Product Mismatch'

        ELSE 'General Dissatisfaction'
    END AS complaint_category,

    COUNT(*) AS total_complaints,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM raw.order_reviews
         WHERE review_score = 1
         AND review_comment_message IS NOT NULL),
        2
    ) AS percentage

FROM raw.order_reviews
WHERE review_score = 1
AND review_comment_message IS NOT NULL

GROUP BY complaint_category
ORDER BY total_complaints DESC;

SELECT
    COUNT(*) AS total_delivered_orders,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date >
              order_estimated_delivery_date
    ) AS late_delivered_orders,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date <=
              order_estimated_delivery_date
    ) AS on_time_or_early_orders

FROM raw.orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
AND order_estimated_delivery_date IS NOT NULL;

SELECT
    ROUND(
        PERCENTILE_CONT(0.50) WITHIN GROUP (
            ORDER BY EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date -
                    order_estimated_delivery_date
                )
            ) / 86400
        )::numeric,
        2
    ) AS median_delay_days
FROM raw.orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date >
    order_estimated_delivery_date;

SELECT
    CASE
        WHEN delay_days <= 3 THEN '1-3 Days'
        WHEN delay_days <= 7 THEN '4-7 Days'
        ELSE 'More than 7 Days'
    END AS delay_category,

    COUNT(*) AS total_orders,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage

FROM (
    SELECT
        EXTRACT(
            EPOCH FROM (
                order_delivered_customer_date -
                order_estimated_delivery_date
            )
        ) / 86400 AS delay_days
    FROM raw.orders
    WHERE order_status = 'delivered'
    AND order_delivered_customer_date >
        order_estimated_delivery_date
) AS delayed_orders

GROUP BY delay_category
ORDER BY MIN(delay_days);

SELECT
    TO_CHAR(
        order_purchase_timestamp,
        'YYYY-MM'
    ) AS purchase_month,

    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'delivered'
        AND order_delivered_customer_date >
            order_estimated_delivery_date
    ) AS late_orders,

    ROUND(
        COUNT(*) FILTER (
            WHERE order_status = 'delivered'
            AND order_delivered_customer_date >
                order_estimated_delivery_date
        ) * 100.0 /
        NULLIF(
            COUNT(*) FILTER (
                WHERE order_status = 'delivered'
                AND order_delivered_customer_date IS NOT NULL
                AND order_estimated_delivery_date IS NOT NULL
            ),
            0
        ),
        2
    ) AS late_delivery_percentage

FROM raw.orders

GROUP BY purchase_month
ORDER BY purchase_month;

SELECT
    TO_CHAR(order_purchase_timestamp, 'YYYY-MM') AS purchase_month,

    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'delivered'
        AND order_delivered_customer_date IS NOT NULL
        AND order_estimated_delivery_date IS NOT NULL
    ) AS delivered_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'delivered'
        AND order_delivered_customer_date >
            order_estimated_delivery_date
    ) AS late_orders,

    ROUND(
        COUNT(*) FILTER (
            WHERE order_status = 'delivered'
            AND order_delivered_customer_date >
                order_estimated_delivery_date
        ) * 100.0 /
        NULLIF(
            COUNT(*) FILTER (
                WHERE order_status = 'delivered'
                AND order_delivered_customer_date IS NOT NULL
                AND order_estimated_delivery_date IS NOT NULL
            ),
            0
        ),
        2
    ) AS late_delivery_percentage

FROM raw.orders
GROUP BY purchase_month
ORDER BY purchase_month;

SELECT
    oi.seller_id,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT o.order_id) FILTER (
        WHERE o.order_delivered_customer_date >
              o.order_estimated_delivery_date
    ) AS late_orders,

    ROUND(
        COUNT(DISTINCT o.order_id) FILTER (
            WHERE o.order_delivered_customer_date >
                  o.order_estimated_delivery_date
        ) * 100.0 /
        COUNT(DISTINCT o.order_id),
        2
    ) AS late_delivery_percentage

FROM raw.orders o

JOIN raw.order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY oi.seller_id

HAVING COUNT(DISTINCT o.order_id) >= 20

ORDER BY late_delivery_percentage DESC

LIMIT 20;

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT o.order_id) FILTER (
        WHERE o.order_delivered_customer_date >
              o.order_estimated_delivery_date
    ) AS late_orders,

    ROUND(
        COUNT(DISTINCT o.order_id) FILTER (
            WHERE o.order_delivered_customer_date >
                  o.order_estimated_delivery_date
        ) * 100.0 /
        COUNT(DISTINCT o.order_id),
        2
    ) AS late_delivery_percentage

FROM raw.orders o

JOIN raw.order_items oi
    ON o.order_id = oi.order_id

JOIN raw.sellers s
    ON oi.seller_id = s.seller_id

WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state

HAVING COUNT(DISTINCT o.order_id) >= 50

ORDER BY late_delivery_percentage DESC

LIMIT 20;


SELECT
    c.customer_state,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT o.order_id) FILTER (
        WHERE o.order_delivered_customer_date >
              o.order_estimated_delivery_date
    ) AS late_orders,

    ROUND(
        COUNT(DISTINCT o.order_id) FILTER (
            WHERE o.order_delivered_customer_date >
                  o.order_estimated_delivery_date
        ) * 100.0 /
        COUNT(DISTINCT o.order_id),
        2
    ) AS late_delivery_percentage

FROM raw.orders o

JOIN raw.customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY c.customer_state

HAVING COUNT(DISTINCT o.order_id) >= 100

ORDER BY late_delivery_percentage DESC;

WITH seller_orders AS (
    SELECT DISTINCT
        o.order_id,
        oi.seller_id,
        s.seller_state,
        c.customer_state,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date

    FROM raw.orders o

    JOIN raw.order_items oi
        ON o.order_id = oi.order_id

    JOIN raw.sellers s
        ON oi.seller_id = s.seller_id

    JOIN raw.customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
)

SELECT
    CASE
        WHEN seller_state = customer_state
        THEN 'Same State'
        ELSE 'Interstate'
    END AS delivery_type,

    COUNT(*) AS total_seller_orders,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date >
              order_estimated_delivery_date
    ) AS late_orders,

    ROUND(
        COUNT(*) FILTER (
            WHERE order_delivered_customer_date >
                  order_estimated_delivery_date
        ) * 100.0 / COUNT(*),
        2
    ) AS late_delivery_percentage

FROM seller_orders

GROUP BY delivery_type
ORDER BY late_delivery_percentage DESC;

SELECT
    s.seller_state,
    c.customer_state,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT o.order_id) FILTER (
        WHERE o.order_delivered_customer_date >
              o.order_estimated_delivery_date
    ) AS late_orders,

    ROUND(
        COUNT(DISTINCT o.order_id) FILTER (
            WHERE o.order_delivered_customer_date >
                  o.order_estimated_delivery_date
        ) * 100.0 /
        COUNT(DISTINCT o.order_id),
        2
    ) AS late_delivery_percentage

FROM raw.orders o

JOIN raw.customers c
    ON o.customer_id = c.customer_id

JOIN raw.order_items oi
    ON o.order_id = oi.order_id

JOIN raw.sellers s
    ON oi.seller_id = s.seller_id

WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
AND o.order_estimated_delivery_date IS NOT NULL
AND s.seller_state <> c.customer_state

GROUP BY s.seller_state, c.customer_state

HAVING COUNT(DISTINCT o.order_id) >= 50

ORDER BY late_delivery_percentage DESC
LIMIT 20;
SELECT
    s.seller_state,
    c.customer_state,

    COUNT(DISTINCT o.order_id) AS late_orders,

    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (
                o.order_delivered_customer_date -
                o.order_estimated_delivery_date
            )) / 86400
        )::numeric,
        2
    ) AS average_delay_days,

    ROUND(
        MAX(
            EXTRACT(EPOCH FROM (
                o.order_delivered_customer_date -
                o.order_estimated_delivery_date
            )) / 86400
        )::numeric,
        2
    ) AS maximum_delay_days

FROM raw.orders o

JOIN raw.customers c
    ON o.customer_id = c.customer_id

JOIN raw.order_items oi
    ON o.order_id = oi.order_id

JOIN raw.sellers s
    ON oi.seller_id = s.seller_id

WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date >
    o.order_estimated_delivery_date
AND o.order_delivered_customer_date IS NOT NULL
AND o.order_estimated_delivery_date IS NOT NULL
AND s.seller_state <> c.customer_state

GROUP BY s.seller_state, c.customer_state

HAVING COUNT(DISTINCT o.order_id) >= 50

ORDER BY average_delay_days DESC
LIMIT 20;


WITH order_routes AS (
    SELECT DISTINCT
        o.order_id,
        s.seller_state,
        c.customer_state,

        EXTRACT(EPOCH FROM (
            o.order_delivered_customer_date -
            o.order_estimated_delivery_date
        )) / 86400 AS delay_days

    FROM raw.orders o

    JOIN raw.customers c
        ON o.customer_id = c.customer_id

    JOIN raw.order_items oi
        ON o.order_id = oi.order_id

    JOIN raw.sellers s
        ON oi.seller_id = s.seller_id

    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date >
          o.order_estimated_delivery_date
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
      AND s.seller_state <> c.customer_state
)

SELECT
    seller_state,
    customer_state,
    COUNT(*) AS seller_order_routes,
    ROUND(AVG(delay_days)::numeric, 2) AS average_delay_days,
    ROUND(MAX(delay_days)::numeric, 2) AS maximum_delay_days

FROM order_routes

GROUP BY seller_state, customer_state

HAVING COUNT(*) >= 50

ORDER BY average_delay_days DESC
LIMIT 20;

SELECT
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late Delivery'
        ELSE 'On-time or Early'
    END AS delivery_category,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(AVG(r.review_score), 2) AS average_review_score,

    COUNT(r.review_id) AS total_reviews

FROM raw.orders o

JOIN raw.order_reviews r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY delivery_category
ORDER BY average_review_score;

SELECT
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late Delivery'
        ELSE 'On-time or Early'
    END AS delivery_category,

    COUNT(r.review_id) AS total_reviews,

    COUNT(r.review_id) FILTER (
        WHERE r.review_score = 1
    ) AS one_star_reviews,

    ROUND(
        COUNT(r.review_id) FILTER (
            WHERE r.review_score = 1
        ) * 100.0 /
        NULLIF(COUNT(r.review_id), 0),
        2
    ) AS one_star_percentage

FROM raw.orders o

JOIN raw.order_reviews r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY delivery_category
ORDER BY one_star_percentage DESC;


WITH late_order_reviews AS (
    SELECT
        o.order_id,

        EXTRACT(EPOCH FROM (
            o.order_delivered_customer_date -
            o.order_estimated_delivery_date
        )) / 86400 AS delay_days,

        r.review_score

    FROM raw.orders o

    JOIN raw.order_reviews r
        ON o.order_id = r.order_id

    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date >
          o.order_estimated_delivery_date
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
),

delay_groups AS (
    SELECT
        CASE
            WHEN delay_days <= 3 THEN '1-3 Days'
            WHEN delay_days <= 7 THEN '4-7 Days'
            WHEN delay_days <= 14 THEN '8-14 Days'
            ELSE 'More than 14 Days'
        END AS delay_category,

        delay_days,
        review_score

    FROM late_order_reviews
)

SELECT
    delay_category,

    COUNT(*) AS total_reviews,

    ROUND(AVG(review_score), 2) AS average_rating,

    COUNT(*) FILTER (
        WHERE review_score = 1
    ) AS one_star_reviews,

    ROUND(
        COUNT(*) FILTER (
            WHERE review_score = 1
        ) * 100.0 / COUNT(*),
        2
    ) AS one_star_percentage

FROM delay_groups

GROUP BY delay_category

ORDER BY MIN(delay_days);


SELECT
    COALESCE(
        pct.product_category_name_english,
        'Unknown'
    ) AS product_category,

    COUNT(*) AS total_reviews,

    ROUND(AVG(r.review_score), 2) AS average_rating,

    COUNT(*) FILTER (
        WHERE r.review_score = 1
    ) AS one_star_reviews,

    ROUND(
        COUNT(*) FILTER (
            WHERE r.review_score = 1
        ) * 100.0 / COUNT(*),
        2
    ) AS one_star_percentage

FROM raw.orders o

JOIN raw.order_reviews r
    ON o.order_id = r.order_id

JOIN raw.order_items oi
    ON o.order_id = oi.order_id

JOIN raw.products p
    ON oi.product_id = p.product_id

LEFT JOIN raw.product_category_name_translation pct
    ON p.product_category_name = pct.product_category_name

WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date >
    o.order_estimated_delivery_date
AND o.order_delivered_customer_date IS NOT NULL
AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY product_category

HAVING COUNT(*) >= 50

ORDER BY one_star_percentage DESC;

SELECT
    COALESCE(
        pct.product_category_name_english,
        'Unknown'
    ) AS product_category,

    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late Delivery'
        ELSE 'On-time or Early'
    END AS delivery_category,

    COUNT(*) AS total_reviews,

    ROUND(AVG(r.review_score), 2) AS average_rating,

    ROUND(
        COUNT(*) FILTER (
            WHERE r.review_score = 1
        ) * 100.0 / COUNT(*),
        2
    ) AS one_star_percentage

FROM raw.orders o

JOIN raw.order_reviews r
    ON o.order_id = r.order_id

JOIN raw.order_items oi
    ON o.order_id = oi.order_id

JOIN raw.products p
    ON oi.product_id = p.product_id

LEFT JOIN raw.product_category_name_translation pct
    ON p.product_category_name = pct.product_category_name

WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY
    product_category,
    delivery_category

HAVING COUNT(*) >= 50

ORDER BY product_category, delivery_category;

SELECT
    COUNT(*) AS total_payment_records,

    ROUND(
        SUM(payment_value)::numeric,
        2
    ) AS total_payment_value,

    ROUND(
        AVG(payment_value)::numeric,
        2
    ) AS average_payment_value

FROM raw.order_payments;

SELECT
    payment_type,

    COUNT(*) AS total_payment_records,

    ROUND(
        SUM(payment_value)::numeric,
        2
    ) AS total_payment_value,

    ROUND(
        AVG(payment_value)::numeric,
        2
    ) AS average_payment_value,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS payment_record_percentage

FROM raw.order_payments

GROUP BY payment_type

ORDER BY total_payment_value DESC;

SELECT
    COUNT(DISTINCT order_id) AS total_orders,

    ROUND(
        SUM(payment_value)::numeric,
        2
    ) AS total_payment_value,

    ROUND(
        (
            SUM(payment_value) /
            COUNT(DISTINCT order_id)
        )::numeric,
        2
    ) AS average_order_value

FROM raw.order_payments;

SELECT
    payment_installments,

    COUNT(DISTINCT order_id) AS total_orders,

    ROUND(
        SUM(payment_value)::numeric,
        2
    ) AS total_payment_value,

    ROUND(
        AVG(payment_value)::numeric,
        2
    ) AS average_payment_value

FROM raw.order_payments

GROUP BY payment_installments

ORDER BY payment_installments;