-- Aggregates all order and review history per unique customer.
-- Grain: one row per customer_unique_id.
WITH orders AS (
    SELECT * FROM {{ ref('int_orders_enriched') }}
)

SELECT
    customer_unique_id,
    COUNT(order_id)                             AS total_orders,
    MIN(ordered_at)                             AS first_order_at,
    MAX(ordered_at)                             AS last_order_at,
    DATEDIFF('day', MIN(ordered_at), MAX(ordered_at))
                                                AS customer_lifespan_days,
    SUM(total_payment_amount_brl)               AS total_revenue_brl,
    AVG(total_payment_amount_brl)               AS avg_order_value_brl,
    AVG(review_rating)                          AS avg_review_rating,
    SUM(CASE WHEN is_delivered THEN 1 ELSE 0 END)
                                                AS delivered_orders,
    CASE WHEN COUNT(order_id) > 1 THEN TRUE ELSE FALSE END
                                                AS is_repeat_customer
FROM orders
GROUP BY customer_unique_id
