WITH source AS (
    SELECT * FROM {{ source('raw', 'order_payments') }}
)

SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value                   AS payment_amount_brl,
    CURRENT_TIMESTAMP               AS _loaded_at
FROM source
