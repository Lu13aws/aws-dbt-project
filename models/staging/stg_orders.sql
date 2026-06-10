WITH source AS (
    SELECT * FROM {{ source('raw', 'orders') }}
)

SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp        AS ordered_at,
    order_approved_at               AS approved_at,
    order_delivered_carrier_date    AS shipped_at,
    order_delivered_customer_date   AS delivered_at,
    order_estimated_delivery_date   AS estimated_delivery_at,
    CASE
        WHEN order_status = 'delivered' THEN TRUE
        ELSE FALSE
    END                             AS is_delivered,
    CURRENT_TIMESTAMP               AS _loaded_at
FROM source
