-- Olist products â€” ~33K rows
-- Source file: olist_products_dataset.csv
-- Note: column names in CSV have typos (lenght vs length) â€” preserved here for fidelity

CREATE TABLE IF NOT EXISTS "raw".products (
    product_id                  VARCHAR(50),
    product_category_name       VARCHAR(100),
    product_name_lenght         INTEGER,
    product_description_lenght  INTEGER,
    product_photos_qty          INTEGER,
    product_weight_g            INTEGER,
    product_length_cm           INTEGER,
    product_height_cm           INTEGER,
    product_width_cm            INTEGER
);

COPY "raw".products
FROM 's3://olist-raw-data-759302162548-eu-central-1-an/raw/products/olist_products_dataset.csv'
IAM_ROLE 'arn:aws:iam::759302162548:role/redshift-s3-copy-role'
CSV
IGNOREHEADER 1
REGION 'eu-central-1';

