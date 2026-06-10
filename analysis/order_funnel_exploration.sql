-- Ad-hoc: Order funnel — how many orders reach each status stage?
-- Run with: dbt compile --select analysis/order_funnel_exploration
-- Then execute the compiled SQL in Redshift Query Editor.
SELECT
    order_status,
    COUNT(*)                                        AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct_of_total
FROM {{ ref('stg_orders') }}
GROUP BY order_status
ORDER BY order_count DESC
