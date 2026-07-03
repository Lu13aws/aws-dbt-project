-- Enriches products with English category names from the seed translation table.
-- The Olist translation CSV has duplicate PT entries; deduplicate before joining.
WITH products AS (
    SELECT * FROM {{ ref('stg_products') }}
),

translations AS (
    -- Deduplicate: if a PT name appears twice, keep one EN label (MAX is deterministic)
    SELECT
        product_category_name,
        MAX(product_category_name_english) AS product_category_name_english
    FROM {{ ref('product_category_name_translation') }}
    GROUP BY product_category_name
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
