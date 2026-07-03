-- Combines orders with aggregated payment data and computes delivery metrics.
-- Grain: one row per order.
WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

-- Aggregate payments: one order can have multiple payment rows (installments / multiple methods)
-- Redshift limitation: LISTAGG and COUNT(DISTINCT) cannot appear in the same query, so split into two CTEs.
payments_metrics AS (
    SELECT
        order_id,
        SUM(payment_amount_brl)         AS total_payment_amount_brl,
        MAX(payment_installments)       AS max_payment_installments,
        COUNT(DISTINCT payment_type)    AS payment_method_count
    FROM {{ ref('stg_order_payments') }}
    GROUP BY order_id
),

payments_types AS (
    SELECT
        order_id,
        LISTAGG(payment_type, ', ') WITHIN GROUP (ORDER BY payment_type)
                                        AS payment_types_used
    FROM (
        SELECT DISTINCT order_id, payment_type
        FROM {{ ref('stg_order_payments') }}
    ) deduped
    GROUP BY order_id
),

payments_agg AS (
    SELECT
        m.order_id,
        m.total_payment_amount_brl,
        m.max_payment_installments,
        m.payment_method_count,
        t.payment_types_used
    FROM payments_metrics AS m
    LEFT JOIN payments_types AS t ON m.order_id = t.order_id
),

-- Latest review per order (a small number of orders have duplicate reviews)
reviews_latest AS (
    SELECT order_id, review_rating
    FROM (
        SELECT
            order_id,
            review_rating,
            ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_answered_at DESC) AS rn
        FROM {{ ref('stg_order_reviews') }}
    ) ranked
    WHERE rn = 1
),

customers AS (
    SELECT customer_id, customer_unique_id
    FROM {{ ref('stg_customers') }}
)

SELECT
    o.order_id,
    c.customer_unique_id,
    o.order_status,
    o.ordered_at,
    o.approved_at,
    o.shipped_at,
    o.delivered_at,
    o.estimated_delivery_at,
    o.is_delivered,
    {{ classify_delivery_status('o.delivered_at', 'o.estimated_delivery_at') }}
                                        AS delivery_status,
    DATEDIFF('day', o.ordered_at, o.delivered_at)
                                        AS delivery_days,
    DATEDIFF('day', o.ordered_at, o.estimated_delivery_at)
                                        AS estimated_delivery_days,
    p.total_payment_amount_brl,
    p.max_payment_installments,
    p.payment_method_count,
    p.payment_types_used,
    r.review_rating
FROM orders AS o
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
LEFT JOIN payments_agg AS p
    ON o.order_id = p.order_id
LEFT JOIN reviews_latest AS r
    ON o.order_id = r.order_id
