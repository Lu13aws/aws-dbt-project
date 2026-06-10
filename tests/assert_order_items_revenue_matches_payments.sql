-- Validates that total item revenue (price + freight) roughly matches total payments per order.
-- The Olist dataset has some legitimate discrepancies (vouchers, rounding).
-- Returns rows where the gap exceeds 5% of item revenue — these should be investigated.
-- Test passes when this query returns 0 rows.
WITH items_total AS (
    SELECT
        order_id,
        SUM(item_price_brl + freight_value_brl) AS items_revenue_brl
    FROM {{ ref('stg_order_items') }}
    GROUP BY order_id
),

payments_total AS (
    SELECT
        order_id,
        SUM(payment_amount_brl) AS payments_revenue_brl
    FROM {{ ref('stg_order_payments') }}
    GROUP BY order_id
)

SELECT
    i.order_id,
    i.items_revenue_brl,
    p.payments_revenue_brl,
    ABS(i.items_revenue_brl - p.payments_revenue_brl) AS discrepancy_brl
FROM items_total AS i
INNER JOIN payments_total AS p
    ON i.order_id = p.order_id
WHERE ABS(i.items_revenue_brl - p.payments_revenue_brl)
    > (i.items_revenue_brl * 0.05)
