-- Enriches products with English category names from the seed translation table.
-- Products with no matching category in the seed get NULL for the English name.
WITH products AS (
    SELECT * FROM {{ ref('stg_products') }}
),

translations AS (
    SELECT * FROM {{ ref('product_category_name_translation') }}
)

SELECT
    p.product_id,
    p.product_category_name_pt,
    t.product_category_name_english,
    p.product_name_length,
    p.product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM products AS p
LEFT JOIN translations AS t
    ON p.product_category_name_pt = t.product_category_name
