WITH source AS (
    SELECT * FROM {{ source('raw', 'order_reviews') }}
)

SELECT
    review_id,
    order_id,
    review_score                    AS review_rating,
    review_creation_date            AS review_created_at,
    review_answer_timestamp         AS review_answered_at,
    CURRENT_TIMESTAMP               AS _loaded_at
FROM source
