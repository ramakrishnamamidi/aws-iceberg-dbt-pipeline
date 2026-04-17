-- snowflake/iceberg_tables.sql

-- Snowflake Managed Iceberg table = data stored on Snowflake-managed S3
-- This is the "Publish" layer in the architecture

CREATE ICEBERG TABLE insurance_dw.marts.policies_publish (
  policy_id       VARCHAR,
  customer_id     VARCHAR,
  product_type    VARCHAR,
  state           VARCHAR(2),
  premium_amount  FLOAT,
  annual_premium  FLOAT,
  coverage_amount NUMBER,
  coverage_to_premium_ratio FLOAT,
  policy_status   VARCHAR,
  policy_start_date DATE,
  dbt_processed_at TIMESTAMP
)
CATALOG = 'SNOWFLAKE'
EXTERNAL_VOLUME = 'insurance_iceberg_vol'
BASE_LOCATION = 'publish/policies/';