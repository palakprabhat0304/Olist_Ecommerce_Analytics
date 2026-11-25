
-- =========================================
-- PROJECT: OLIST E-COMMERCE DATA ANALYSIS
-- SECTION 2: CUSTOMER & REVIEW ANALYSIS
-- =========================================


-- 1. Total customer records and unique customers

SELECT
    COUNT(*) AS total_customer_records,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM raw.customers;


-- 2. Identify repeat customers

SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders
    FROM raw.customers c
    JOIN raw.orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(o.order_id) > 1
) AS repeat_customer_list;


-- 3. Repeat customer percentage

SELECT
    COUNT(*) AS total_unique_customers,
    COUNT(*) FILTER (WHERE total_orders > 1) AS repeat_customers,
    ROUND(
        COUNT(*) FILTER (WHERE total_orders > 1) * 100.0
        / COUNT(*), 2
    ) AS repeat_customer_percentage
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders
    FROM raw.customers c
    JOIN raw.orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS customer_orders;


-- 4. Overall customer review analysis

SELECT
    COUNT(*) AS total_reviews,
    ROUND(AVG(review_score), 2) AS average_review_score,
    COUNT(*) FILTER (WHERE review_score >= 4) AS positive_reviews,
    COUNT(*) FILTER (WHERE review_score <= 2) AS negative_reviews
FROM raw.order_reviews;


-- 5. Review score distribution

SELECT
    review_score,
    COUNT(*) AS total_reviews,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS review_percentage
FROM raw.order_reviews
GROUP BY review_score
ORDER BY review_score DESC;


-- 6. One-star review analysis

SELECT
    COUNT(*) AS total_one_star_reviews,
    COUNT(*) FILTER (
        WHERE review_comment_message IS NOT NULL
    ) AS reviews_with_comments,
    COUNT(*) FILTER (
        WHERE review_comment_message IS NULL
    ) AS reviews_without_comments
FROM raw.order_reviews
WHERE review_score = 1;


-- 7. Extract comments from one-star reviews

SELECT
    review_comment_message
FROM raw.order_reviews
WHERE review_score = 1
  AND review_comment_message IS NOT NULL;


-- 8. Classify one-star review complaints

WITH complaint_categories AS (
    SELECT
        CASE
            WHEN LOWER(review_comment_message) LIKE '%entrega%'
              OR LOWER(review_comment_message) LIKE '%atras%'
              OR LOWER(review_comment_message) LIKE '%chegar%'
              OR LOWER(review_comment_message) LIKE '%recebi%'
              OR LOWER(review_comment_message) LIKE '%prazo%'
              OR LOWER(review_comment_message) LIKE '%entregue%'
                THEN 'Delivery Issues'

            WHEN LOWER(review_comment_message) LIKE '%falt%'
              OR LOWER(review_comment_message) LIKE '%missing%'
                THEN 'Missing Items'

            WHEN LOWER(review_comment_message) LIKE '%quebrad%'
              OR LOWER(review_comment_message) LIKE '%defeit%'
              OR LOWER(review_comment_message) LIKE '%danific%'
                THEN 'Product Quality or Damage'

            WHEN LOWER(review_comment_message) LIKE '%diferente%'
              OR LOWER(review_comment_message) LIKE '%errado%'
              OR LOWER(review_comment_message) LIKE '%wrong%'
                THEN 'Product Mismatch'

            WHEN LOWER(review_comment_message) LIKE '%atendimento%'
              OR LOWER(review_comment_message) LIKE '%reembolso%'
              OR LOWER(review_comment_message) LIKE '%devolu%'
                THEN 'Customer Support and Returns'

            WHEN LOWER(review_comment_message) LIKE '%nota fiscal%'
              OR LOWER(review_comment_message) LIKE '%fiscal%'
                THEN 'Invoice Issues'

            ELSE 'General Dissatisfaction'
        END AS complaint_category
    FROM raw.order_reviews
    WHERE review_score = 1
      AND review_comment_message IS NOT NULL
)

SELECT
    complaint_category,
    COUNT(*) AS total_complaints,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS complaint_percentage
FROM complaint_categories
GROUP BY complaint_category
ORDER BY total_complaints DESC;
