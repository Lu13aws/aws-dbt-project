-- Customer dimension. Grain: one row per unique customer (person).
-- customer_unique_id is the durable person-level key in the Olist dataset.
WITH customer_orders AS (
    SELECT * FROM {{ ref('int_customer_orders') }}
),

customers AS (
    -- One customer_unique_id can have multiple customer_id rows; use DISTINCT ON latest
    SELECT DISTINCT ON (customer_unique_id)
        customer_unique_id,
        customer_city,
        customer_state,
        zip_code_prefix
    FROM {{ ref('stg_customers') }}
    ORDER BY customer_unique_id
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['c.customer_unique_id']) }}
                                    AS customer_key,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    c.zip_code_prefix,
    co.total_orders,
    co.first_order_at,
    co.last_order_at,
    co.customer_lifespan_days,
    co.total_revenue_brl,
    co.avg_order_value_brl,
    co.avg_review_rating,
    co.delivered_orders,
    co.is_repeat_customer
FROM customers AS c
LEFT JOIN customer_orders AS co
    ON c.customer_unique_id = co.customer_unique_id
