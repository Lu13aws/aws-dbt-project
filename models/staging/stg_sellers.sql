WITH source AS (
    SELECT * FROM {{ source('raw', 'sellers') }}
)

SELECT
    seller_id,
    seller_zip_code_prefix          AS zip_code_prefix,
    seller_city,
    seller_state,
    CURRENT_TIMESTAMP               AS _loaded_at
FROM source
