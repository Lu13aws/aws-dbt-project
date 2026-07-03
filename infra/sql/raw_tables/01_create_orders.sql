-- Olist orders â€” ~99K rows
-- Source file: olist_orders_dataset.csv

CREATE TABLE IF NOT EXISTS "raw".orders (
    order_id                        VARCHAR(50),
    customer_id                     VARCHAR(50),
    order_status                    VARCHAR(20),
    order_purchase_timestamp        TIMESTAMP,
    order_approved_at               TIMESTAMP,
    order_delivered_carrier_date    TIMESTAMP,
    order_delivered_customer_date   TIMESTAMP,
    order_estimated_delivery_date   TIMESTAMP
);

COPY "raw".orders
FROM 's3://olist-raw-data-759302162548-eu-central-1-an/raw/orders/olist_orders_dataset.csv'
IAM_ROLE 'arn:aws:iam::759302162548:role/redshift-s3-copy-role'
CSV
IGNOREHEADER 1
TIMEFORMAT 'YYYY-MM-DD HH:MI:SS'
REGION 'eu-central-1';

