# AWS Iceberg DBT Pipeline - Step-by-Step Guide

## Checklist of Completed Tasks

- [x] Set up Git repository
- [x] Create .gitignore and .env for security
- [x] Generate mock insurance policy data
- [x] Set up AWS S3 bucket (insurance-lakehouse-demo-2026) with prefixes: landing/, idl/, publish/, raw/
- [x] Upload mock_policies.csv to s3://insurance-lakehouse-demo-2026/raw/
- [x] Create IAM roles: EMR_DefaultRole, EMR_EC2_DefaultRole, GlueIcebergRole
- [x] Enable Glue Data Catalog
- [x] Create Glue database: insurance_landing
- [x] Run Glue job to ingest CSV to Iceberg table (policies_raw)
- [x] Run Glue job for IDL transformation (policies_idl with quality checks)
- [x] Set up Athena query result location
- [x] Verify tables in Glue and Athena
- [x] Create .env with variables
- [x] Update profiles.yml to use env vars
- [ ] Sign up for Snowflake (completed by user)
- [ ] Configure Snowflake account details in .env
- [ ] Run Snowflake setup.sql
- [ ] Create IAM role for Snowflake S3 access
- [ ] Create external stage and load data
- [ ] Run iceberg_tables.sql
- [ ] Set up dbt Cloud
- [ ] Connect dbt to Snowflake
- [ ] Run dbt models

## Step-by-Step Guide

### 1. Prerequisites
- AWS account with CLI configured
- Python 3.10+, pandas, faker installed
- Docker installed (optional)
- GitHub account

### 2. Repository Setup
- Clone or create repo: `aws-iceberg-dbt-pipeline`
- Update .gitignore to exclude secrets and generated files
- Create .env file with placeholders

### 3. Data Generation
- Run: `python data/generate_mock_data.py` or use Docker
- Generates 10k insurance policy records

### 4. AWS S3 Setup
- Create bucket: `aws s3 mb s3://insurance-lakehouse-demo-2026 --region ap-south-1`
- Create prefixes: landing/, idl/, publish/, raw/, athena-results/
- Upload CSV: `aws s3 cp data/mock_policies.csv s3://insurance-lakehouse-demo-2026/raw/`

### 5. IAM Roles Setup
- Create EMR_DefaultRole and EMR_EC2_DefaultRole with EMR policies
- Create GlueIcebergRole with S3 and Glue policies
- Enable Glue Data Catalog in ap-south-1

### 6. Glue Database and Jobs
- Create database: insurance_landing
- Create Glue job for CSV ingestion (01_csv_to_iceberg.py)
- Run job, verify policies_raw table
- Create Glue job for IDL (02_transform_to_idl.py)
- Run job, verify policies_idl table with new columns

### 7. Athena Setup
- Set query result location: s3://insurance-lakehouse-demo-2026/athena-results/
- Query: `SELECT COUNT(*) FROM insurance_landing.policies_raw;`

### 8. Snowflake Setup
- Sign up: https://signup.snowflake.com
- Account locator: wlufpwz-rq95874
- Update .env with credentials:
  - SNOWFLAKE_USER=your_email
  - SNOWFLAKE_PASSWORD=your_password
  - SNOWFLAKE_ROLE=ACCOUNTADMIN

### 9. Run Snowflake Setup
- In Worksheets, execute snowflake/setup.sql (replace YOUR_ACCOUNT_ID with your AWS account ID, yourname with your bucket suffix)
- Note STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID from DESC INTEGRATION

### 10. Create AWS IAM Role for Snowflake
- In IAM Console, create role: SnowflakeS3Role
- Trust policy:
  ```
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "STORAGE_AWS_IAM_USER_ARN"
        },
        "Action": "sts:AssumeRole",
        "Condition": {
          "StringEquals": {
            "sts:ExternalId": "STORAGE_AWS_EXTERNAL_ID"
          }
        }
      }
    ]
  }
  ```
- Attach AmazonS3ReadOnlyAccess

### 11. Create Snowflake External Stage and Load Data
- Execute:
  ```
  CREATE STAGE insurance_dw.individual_raw.idl_stage
    STORAGE_INTEGRATION = s3_insurance_integration
    URL = 's3://insurance-lakehouse-demo-2026/idl/'
    FILE_FORMAT = (TYPE = PARQUET);
  ```
- Load:
  ```
  COPY INTO insurance_dw.individual_raw.policies_raw
  FROM @insurance_dw.individual_raw.idl_stage
  FILE_FORMAT = (TYPE = PARQUET)
  MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
  ```
- Verify: `SELECT COUNT(*) FROM insurance_dw.individual_raw.policies_raw;`

### 12. Create Snowflake-Managed Iceberg Table
- Execute snowflake/iceberg_tables.sql
- Creates publish layer table

### 13. DBT Setup
- Sign up: https://cloud.getdbt.com/signup
- Create project, connect to GitHub repo
- Connect to Snowflake using .env variables
- Run dbt models: staging, intermediate, marts

### 14. Verification
- Query final mart in Snowflake
- Check dbt lineage in Cloud

## Next Steps
- Complete Snowflake configuration
- Run dbt pipelines
- Explore time travel and schema evolution</content>
<parameter name="filePath">D:\RK\Learning\aws-iceberg-dbt-pipeline\docs\step.md