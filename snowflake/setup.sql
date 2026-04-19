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
   STORAGE_ALLOWED_LOCATIONS = ('s3://insurance-lakehouse-demo-2026/');

-- Get the Snowflake IAM values (add to your AWS role trust policy)
DESC INTEGRATION s3_insurance_integration;