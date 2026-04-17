# AWS Iceberg DBT Pipeline

This project implements a modern data lakehouse for insurance policy analytics using AWS, Snowflake, dbt, and Apache Iceberg.

## Project Structure

- `data/`: Mock data generation scripts and CSV files
- `glue_jobs/`: AWS Glue ETL scripts for data ingestion
- `emr_jobs/`: AWS EMR PySpark jobs for data transformation
- `snowflake/`: Snowflake setup and DDL scripts
- `dbt_project/`: dbt models for data transformation
- `docs/`: Documentation and diagrams

See roadmap.md for detailed setup instructions and phases.

## Getting Started

1. Generate mock data: `python data/generate_mock_data.py`
2. Follow the phases in roadmap.md