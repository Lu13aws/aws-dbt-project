-- Customer dimension. Grain: one row per unique customer (person).
-- customer_unique_id is the durable person-level key in the Olist dataset.
WITH customer_orders AS (
    SELECT * FROM {{ ref('int_customer_orders') }}
),

customers AS (
    -- One customer_unique_id can have multiple customer_id rows; keep one per person
    SELECT customer_unique_id, customer_city, customer_state, zip_code_prefix
    FROM (
        SELECT
            customer_unique_id,
            customer_city,
            customer_state,
            zip_code_prefix,
            ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY customer_id) AS rn
        FROM {{ ref('stg_customers') }}
    ) ranked
    WHERE rn = 1
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['c.customer_unique_id']) }}
                                    AS customer_key,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    c.zip_code_prefix,
    COALESCE(co.total_orders, 0)            AS total_orders,
    co.first_order_at,
    co.last_order_at,
    COALESCE(co.customer_lifespan_days, 0)  AS customer_lifespan_days,
    COALESCE(co.total_revenue_brl, 0)       AS total_revenue_brl,
    COALESCE(co.avg_order_value_brl, 0)     AS avg_order_value_brl,
    co.avg_review_rating,
    COALESCE(co.delivered_orders, 0)        AS delivered_orders,
    COALESCE(co.is_repeat_customer, FALSE)  AS is_repeat_customer
FROM customers AS c
LEFT JOIN customer_orders AS co
    ON c.customer_unique_id = co.customer_unique_id
