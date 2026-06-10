-- Order line items fact table. Grain: one row per order line item (order_id + order_item_id).
-- Use for product-level and seller-level revenue analysis.
WITH order_items AS (
    SELECT * FROM {{ ref('int_order_items_enriched') }}
),

dim_products AS (
    SELECT product_key, product_id
    FROM {{ ref('dim_products') }}
),

dim_sellers AS (
    SELECT seller_key, seller_id
    FROM {{ ref('dim_sellers') }}
),

dim_customers AS (
    SELECT customer_key, customer_unique_id
    FROM {{ ref('dim_customers') }}
),

orders AS (
    SELECT order_id, customer_unique_id, ordered_at
    FROM {{ ref('fct_orders') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['oi.order_id', 'oi.order_item_id']) }}
                                    AS order_item_key,
    oi.order_id,
    oi.order_item_id,
    dp.product_key,
    ds.seller_key,
    dc.customer_key,
    o.ordered_at::DATE              AS order_date_key,
    oi.product_category_name_english,
    oi.item_price_brl,
    oi.freight_value_brl,
    oi.total_item_revenue_brl,
    oi.product_weight_g,
    oi.seller_city,
    oi.seller_state
FROM order_items AS oi
LEFT JOIN dim_products AS dp
    ON oi.product_id = dp.product_id
LEFT JOIN dim_sellers AS ds
    ON oi.seller_id = ds.seller_id
LEFT JOIN orders AS o
    ON oi.order_id = o.order_id
LEFT JOIN dim_customers AS dc
    ON o.customer_unique_id = dc.customer_unique_id
