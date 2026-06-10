-- Olist order reviews — ~99K rows
-- Source file: olist_order_reviews_dataset.csv

CREATE TABLE IF NOT EXISTS raw.order_reviews (
    review_id               VARCHAR(50),
    order_id                VARCHAR(50),
    review_score            INTEGER,
    review_comment_title    VARCHAR(500),
    review_comment_message  VARCHAR(2000),
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

COPY raw.order_reviews
FROM 's3://<BUCKET>/raw/order_reviews/olist_order_reviews_dataset.csv'
IAM_ROLE '<IAM_ROLE_ARN>'
CSV
IGNOREHEADER 1
TIMEFORMAT 'YYYY-MM-DD HH:MI:SS'
REGION '<REGION>';
