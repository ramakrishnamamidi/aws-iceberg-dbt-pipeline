{{config(materialized='table')}}

WITH policy_base AS (
    SELECT * FROM {{ ref('stg_policies') }}
    WHERE policy_status NOT IN ('CANCELLED')
),

agent_stats AS (
    SELECT
        agent_id,
        COUNT(policy_id)            AS agent_policy_count,
        AVG(premium_amount)         AS agent_avg_premium
    FROM {{ ref('stg_policies') }}
    GROUP BY agent_id
)

SELECT
    p.*,
    a.agent_policy_count,
    a.agent_avg_premium,
    DATEDIFF('month', p.policy_start_date, CURRENT_DATE()) AS policy_age_months
FROM policy_base p
LEFT JOIN agent_stats a USING (agent_id)