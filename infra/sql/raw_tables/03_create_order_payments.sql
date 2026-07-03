-- Olist order payments â€” ~104K rows (multiple rows per order for installments)
-- Source file: olist_order_payments_dataset.csv

CREATE TABLE IF NOT EXISTS "raw".order_payments (
    order_id                VARCHAR(50),
    payment_sequential      INTEGER,
    payment_type            VARCHAR(30),
    payment_installments    INTEGER,
    payment_value           DECIMAL(10, 2)
);

COPY "raw".order_payments
FROM 's3://olist-raw-data-759302162548-eu-central-1-an/raw/order_payments/olist_order_payments_dataset.csv'
IAM_ROLE 'arn:aws:iam::759302162548:role/redshift-s3-copy-role'
CSV
IGNOREHEADER 1
REGION 'eu-central-1';

