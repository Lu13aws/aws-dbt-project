-- Converts a BRL amount column to USD using a configurable exchange rate.
-- Default rate is approximate historical average for the Olist dataset period (2016-2018).
-- Usage: {{ brl_to_usd('total_revenue_brl') }}
--        {{ brl_to_usd('total_revenue_brl', exchange_rate=4.0) }}
{% macro brl_to_usd(column_name, exchange_rate=4.5) %}
    ROUND({{ column_name }} / {{ exchange_rate }}, 2)
{% endmacro %}
