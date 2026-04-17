{{config(
    materialized='incremental',
    unique_key='policy_id',
    on_schema_change='sync_all_columns'
)}}

SELECT
    policy_id,
    customer_id,
    product_type,
    state,
    premium_amount,
    annual_premium,
    coverage_amount,
    coverage_to_premium_ratio,
    policy_status,
    policy_start_date,
    policy_age_months,
    agent_id,
    agent_policy_count,
    agent_avg_premium,
    is_premium_outlier,
    CURRENT_TIMESTAMP()             AS dbt_processed_at

FROM {{ ref('int_policy_summary') }}

{% if is_incremental() %}
WHERE idl_processed_at > (SELECT MAX(dbt_processed_at) FROM {{ this }})
{% endif %}