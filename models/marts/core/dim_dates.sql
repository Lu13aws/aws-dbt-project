-- Date dimension covering the full Olist data range (2016–2018) plus buffer.
-- Generated using dbt_utils.date_spine — no source table needed.
WITH date_spine AS (
    {{
        dbt_utils.date_spine(
            datepart="day",
            start_date="cast('" ~ var('start_date') ~ "' as date)",
            end_date="cast('" ~ var('end_date') ~ "' as date)"
        )
    }}
)

SELECT
    date_day,
    EXTRACT(DOW FROM date_day)                          AS day_of_week_num,
    TO_CHAR(date_day, 'Day')                            AS day_of_week_name,
    EXTRACT(DAY FROM date_day)                          AS day_of_month,
    EXTRACT(MONTH FROM date_day)                        AS month_number,
    TO_CHAR(date_day, 'Month')                          AS month_name,
    EXTRACT(QUARTER FROM date_day)                      AS quarter_number,
    'Q' || EXTRACT(QUARTER FROM date_day)               AS quarter_label,
    EXTRACT(YEAR FROM date_day)                         AS year_number,
    EXTRACT(YEAR FROM date_day) || '-Q' || EXTRACT(QUARTER FROM date_day)
                                                        AS year_quarter,
    TO_CHAR(date_day, 'YYYY-MM')                        AS year_month,
    CASE WHEN EXTRACT(DOW FROM date_day) IN (0, 6) THEN TRUE ELSE FALSE END
                                                        AS is_weekend
FROM date_spine
