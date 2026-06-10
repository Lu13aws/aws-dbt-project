WITH source AS (
    SELECT * FROM {{ source('raw', 'products') }}
)

SELECT
    product_id,
    product_category_name           AS product_category_name_pt,
    product_name_lenght             AS product_name_length,
    product_description_lenght      AS product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    CURRENT_TIMESTAMP               AS _loaded_at
FROM source
