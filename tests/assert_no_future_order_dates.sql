-- Ensures no orders have a purchase timestamp in the future.
-- Returns rows that fail this check. Test passes when query returns 0 rows.
SELECT
    order_id,
    ordered_at
FROM {{ ref('stg_orders') }}
WHERE ordered_at > CURRENT_TIMESTAMP
