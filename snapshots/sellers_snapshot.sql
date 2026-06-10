{% snapshot sellers_snapshot %}

{{
    config(
        target_schema='snapshots',
        strategy='check',
        unique_key='seller_id',
        check_cols=['seller_city', 'seller_state'],
        invalidate_hard_deletes=True
    )
}}

-- SCD Type 2 snapshot of seller location data.
-- Tracks changes to seller_city and seller_state over time.
-- To simulate an update for learning: run UPDATE raw.sellers SET seller_city = 'new_city'
-- WHERE seller_id = '<id>', then re-run dbt snapshot to capture the change.
-- dbt adds: dbt_scd_id, dbt_updated_at, dbt_valid_from, dbt_valid_to
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state,
    CURRENT_TIMESTAMP AS updated_at
FROM {{ source('raw', 'sellers') }}

{% endsnapshot %}
