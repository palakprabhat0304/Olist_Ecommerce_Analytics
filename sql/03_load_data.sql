-- Edit the paths below for your machine.
-- Windows psql example:
-- \copy raw.customers FROM 'C:/olist/olist_customers_dataset.csv' CSV HEADER

\copy raw.customers FROM 'C:/olist/olist_customers_dataset.csv' CSV HEADER;
\copy raw.orders FROM 'C:/olist/olist_orders_dataset.csv' CSV HEADER;
\copy raw.order_items FROM 'C:/olist/olist_order_items_dataset.csv' CSV HEADER;
\copy raw.payments FROM 'C:/olist/olist_order_payments_dataset.csv' CSV HEADER;
\copy raw.products FROM 'C:/olist/olist_products_dataset.csv' CSV HEADER;
