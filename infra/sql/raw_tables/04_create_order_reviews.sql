-- Olist order reviews â€” ~99K rows
-- Source file: olist_order_reviews_dataset.csv

CREATE TABLE IF NOT EXISTS "raw".order_reviews (
    review_id               VARCHAR(50),
    order_id                VARCHAR(50),
    review_score            INTEGER,
    review_comment_title    VARCHAR(500),
    review_comment_message  VARCHAR(2000),
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

COPY "raw".order_reviews
FROM 's3://olist-raw-data-759302162548-eu-central-1-an/raw/order_reviews/olist_order_reviews_dataset.csv'
IAM_ROLE 'arn:aws:iam::759302162548:role/redshift-s3-copy-role'
CSV
IGNOREHEADER 1
TIMEFORMAT 'YYYY-MM-DD HH:MI:SS'
REGION 'eu-central-1';

