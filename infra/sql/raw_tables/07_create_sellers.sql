-- Olist sellers — ~3K rows
-- Source file: olist_sellers_dataset.csv

CREATE TABLE IF NOT EXISTS raw.sellers (
    seller_id               VARCHAR(50),
    seller_zip_code_prefix  VARCHAR(10),
    seller_city             VARCHAR(100),
    seller_state            CHAR(2)
);

COPY raw.sellers
FROM 's3://<BUCKET>/raw/sellers/olist_sellers_dataset.csv'
IAM_ROLE '<IAM_ROLE_ARN>'
CSV
IGNOREHEADER 1
REGION '<REGION>';
