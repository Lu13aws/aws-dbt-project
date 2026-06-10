-- Enriches order line items with product category (English) and seller location.
-- Grain: one row per order line item (order_id + order_item_id).
WITH order_items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),

products AS (
    SELECT * FROM {{ ref('int_product_category_translated') }}
),

sellers AS (
    SELECT * FROM {{ ref('stg_sellers') }}
)

SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.shipping_limit_at,
    oi.item_price_brl,
    oi.freight_value_brl,
    oi.item_price_brl + oi.freight_value_brl
                                    AS total_item_revenue_brl,
    p.product_category_name_pt,
    p.product_category_name_english,
    p.product_weight_g,
    s.seller_city,
    s.seller_state
FROM order_items AS oi
LEFT JOIN products AS p
    ON oi.product_id = p.product_id
LEFT JOIN sellers AS s
    ON oi.seller_id = s.seller_id
