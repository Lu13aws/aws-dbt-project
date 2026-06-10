-- Olist order payments — ~104K rows (multiple rows per order for installments)
-- Source file: olist_order_payments_dataset.csv

CREATE TABLE IF NOT EXISTS raw.order_payments (
    order_id                VARCHAR(50),
    payment_sequential      INTEGER,
    payment_type            VARCHAR(30),
    payment_installments    INTEGER,
    payment_value           DECIMAL(10, 2)
);

COPY raw.order_payments
FROM 's3://<BUCKET>/raw/order_payments/olist_order_payments_dataset.csv'
IAM_ROLE '<IAM_ROLE_ARN>'
CSV
IGNOREHEADER 1
REGION '<REGION>';
