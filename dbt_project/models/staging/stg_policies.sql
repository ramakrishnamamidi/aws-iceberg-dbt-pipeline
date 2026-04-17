{{config(materialized='view')}}

SELECT
    policy_id,
    customer_id,
    UPPER(product_type)                     AS product_type,
    state,
    CAST(premium_amount AS FLOAT)           AS premium_amount,
    CAST(annual_premium AS FLOAT)           AS annual_premium,
    CAST(coverage_amount AS NUMBER)         AS coverage_amount,
    coverage_to_premium_ratio,
    policy_status,
    CAST(policy_start_date AS DATE)         AS policy_start_date,
    is_premium_outlier,
    idl_processed_at                        AS _source_loaded_at

FROM {{ source('individual_raw', 'policies_raw') }}

WHERE policy_id IS NOT NULL  -- basic filter