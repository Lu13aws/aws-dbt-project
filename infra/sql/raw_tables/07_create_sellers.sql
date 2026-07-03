-- Olist sellers â€” ~3K rows
-- Source file: olist_sellers_dataset.csv

CREATE TABLE IF NOT EXISTS "raw".sellers (
    seller_id               VARCHAR(50),
    seller_zip_code_prefix  VARCHAR(10),
    seller_city             VARCHAR(100),
    seller_state            CHAR(2)
);

COPY "raw".sellers
FROM 's3://olist-raw-data-759302162548-eu-central-1-an/raw/sellers/olist_sellers_dataset.csv'
IAM_ROLE 'arn:aws:iam::759302162548:role/redshift-s3-copy-role'
CSV
IGNOREHEADER 1
REGION 'eu-central-1';

