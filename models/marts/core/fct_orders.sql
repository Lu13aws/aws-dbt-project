{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge',
        on_schema_change='append_new_columns'
    )
}}

-- Primary order fact table. Grain: one row per order.
-- Incremental: processes only new orders on subsequent runs using ordered_at.
WITH orders AS (
    SELECT * FROM {{ ref('int_orders_enriched') }}
),

dim_customers AS (
    SELECT customer_key, customer_unique_id
    FROM {{ ref('dim_customers') }}
)

SELECT
    o.order_id,
    dc.customer_key,
    o.customer_unique_id,
    o.ordered_at::DATE              AS order_date_key,
    o.delivered_at::DATE            AS delivery_date_key,
    o.order_status,
    o.delivery_status,
    o.is_delivered,
    o.delivery_days,
    o.estimated_delivery_days,
    o.total_payment_amount_brl,
    o.max_payment_installments,
    o.payment_method_count,
    o.payment_types_used,
    o.review_rating,
    o.ordered_at
FROM orders AS o
LEFT JOIN dim_customers AS dc
    ON o.customer_unique_id = dc.customer_unique_id

{% if is_incremental() %}
WHERE o.ordered_at > (SELECT MAX(ordered_at) FROM {{ this }})
{% endif %}
