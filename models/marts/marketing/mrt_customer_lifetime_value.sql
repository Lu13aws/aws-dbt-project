-- Pre-aggregated customer LTV mart for BI tools and marketing analysis.
-- Grain: one row per unique customer.
-- No foreign keys — fully denormalized for self-service analytics.
WITH customers AS (
    SELECT * FROM {{ ref('dim_customers') }}
)

SELECT
    customer_unique_id,
    customer_city,
    customer_state,
    total_orders,
    first_order_at,
    last_order_at,
    customer_lifespan_days,
    total_revenue_brl,
    avg_order_value_brl,
    {{ brl_to_usd('total_revenue_brl') }}
                                    AS total_revenue_usd,
    {{ brl_to_usd('avg_order_value_brl') }}
                                    AS avg_order_value_usd,
    avg_review_rating,
    is_repeat_customer,
    CASE
        WHEN total_revenue_brl >= 1000 THEN 'HIGH'
        WHEN total_revenue_brl >= 300  THEN 'MID'
        ELSE                                'LOW'
    END                             AS clv_segment,
    CASE
        WHEN customer_lifespan_days > 0
            THEN ROUND(total_revenue_brl / (customer_lifespan_days / 30.0), 2)
        ELSE total_revenue_brl
    END                             AS revenue_per_month_brl
FROM customers
