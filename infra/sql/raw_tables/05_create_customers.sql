-- Olist customers — ~99K rows (note: customer_id is per-order, customer_unique_id is the true person)
-- Source file: olist_customers_dataset.csv

CREATE TABLE IF NOT EXISTS raw.customers (
    customer_id             VARCHAR(50),
    customer_unique_id      VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city           VARCHAR(100),
    customer_state          CHAR(2)
);

COPY raw.customers
FROM 's3://<BUCKET>/raw/customers/olist_customers_dataset.csv'
IAM_ROLE '<IAM_ROLE_ARN>'
CSV
IGNOREHEADER 1
REGION '<REGION>';
