-- Returns a delivery timeliness bucket by comparing actual vs estimated delivery date.
-- Usage: {{ classify_delivery_status('delivered_at', 'estimated_delivery_at') }}
{% macro classify_delivery_status(actual_col, estimated_col) %}
    CASE
        WHEN {{ actual_col }} IS NULL
            THEN 'not_delivered'
        WHEN {{ actual_col }} <= {{ estimated_col }}
            THEN 'on_time'
        WHEN DATEDIFF('day', {{ estimated_col }}, {{ actual_col }}) <= 3
            THEN 'slightly_late'
        WHEN DATEDIFF('day', {{ estimated_col }}, {{ actual_col }}) <= 7
            THEN 'late'
        ELSE
            'very_late'
    END
{% endmacro %}
