-- Olist order items — ~113K rows
-- Source file: olist_order_items_dataset.csv

CREATE TABLE IF NOT EXISTS raw.order_items (
    order_id            VARCHAR(50),
    order_item_id       INTEGER,
    product_id          VARCHAR(50),
    seller_id           VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price               DECIMAL(10, 2),
    freight_value       DECIMAL(10, 2)
);

COPY raw.order_items
FROM 's3://<BUCKET>/raw/order_items/olist_order_items_dataset.csv'
IAM_ROLE '<IAM_ROLE_ARN>'
CSV
IGNOREHEADER 1
TIMEFORMAT 'YYYY-MM-DD HH:MI:SS'
REGION '<REGION>';
