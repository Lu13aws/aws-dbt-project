WITH source AS (
    SELECT * FROM {{ source('raw', 'order_items') }}
)

SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date             AS shipping_limit_at,
    price                           AS item_price_brl,
    freight_value                   AS freight_value_brl,
    CURRENT_TIMESTAMP               AS _loaded_at
FROM source
