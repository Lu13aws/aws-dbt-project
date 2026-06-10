-- Product dimension. Grain: one row per product SKU.
WITH products AS (
    SELECT * FROM {{ ref('int_product_category_translated') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['product_id']) }}
                                    AS product_key,
    product_id,
    product_category_name_pt,
    COALESCE(product_category_name_english, 'unknown')
                                    AS product_category_name_english,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    ROUND(
        (product_length_cm * product_height_cm * product_width_cm)::DECIMAL / 1000,
        2
    )                               AS volume_liters
FROM products
