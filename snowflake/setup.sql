-- snowflake/setup.sql

-- Create dedicated database and schemas
CREATE DATABASE insurance_dw;

CREATE SCHEMA insurance_dw.individual_raw;    -- mirrors your S3 raw
CREATE SCHEMA insurance_dw.staging;           -- dbt staging models
CREATE SCHEMA insurance_dw.marts;             -- final analytics tables

-- Create warehouse (compute cluster)
CREATE WAREHOUSE insurance_wh
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- Create S3 integration (allows Snowflake to read your S3)
CREATE STORAGE INTEGRATION s3_insurance_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
   STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::296588423667:role/SnowflakeS3Role'
   STORAGE_ALLOWED_LOCATIONS = ('s3://insurance-lakehouse-yourname/');

-- Get the Snowflake IAM values (add to your AWS role trust policy)
DESC INTEGRATION s3_insurance_integration;

-- Create individual_raw table
CREATE TABLE insurance_dw.individual_raw.policies_raw (
  policy_id       VARCHAR,
  customer_id     VARCHAR,
  product_type    VARCHAR,
  state           VARCHAR(2),
  premium_amount  FLOAT,
  coverage_amount NUMBER,
  policy_start_date DATE,
  policy_status   VARCHAR,
  agent_id        VARCHAR,
  annual_premium  FLOAT,
  coverage_to_premium_ratio FLOAT,
  is_premium_outlier BOOLEAN,
  idl_processed_at TIMESTAMP
);

-- Create external stage
CREATE STAGE insurance_dw.individual_raw.idl_stage
  STORAGE_INTEGRATION = s3_insurance_integration
  URL = 's3://insurance-lakehouse-demo-2026/idl/'
  FILE_FORMAT = (TYPE = PARQUET);

-- Load data
COPY INTO insurance_dw.individual_raw.policies_raw
FROM @insurance_dw.individual_raw.idl_stage
FILE_FORMAT = (TYPE = PARQUET)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;