import sys
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.context import SparkContext
from pyspark.sql import functions as F

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

# Iceberg config — tells Spark to use Iceberg table format
spark.conf.set("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions")
spark.conf.set("spark.sql.catalog.glue_catalog", "org.apache.iceberg.spark.SparkCatalog")
spark.conf.set("spark.sql.catalog.glue_catalog.warehouse", "s3://insurance-lakehouse-yourname/landing/")
spark.conf.set("spark.sql.catalog.glue_catalog.catalog-impl", "org.apache.iceberg.aws.glue.GlueCatalog")
spark.conf.set("spark.sql.catalog.glue_catalog.io-impl", "org.apache.iceberg.aws.s3.S3FileIO")

BUCKET = "insurance-lakehouse-yourname"
SOURCE_PATH = f"s3://{BUCKET}/raw/mock_policies.csv"

# Read CSV
df = spark.read.option("header", True).option("inferSchema", True).csv(SOURCE_PATH)

# Add metadata columns (standard practice)
df = df.withColumn("ingestion_timestamp", F.current_timestamp()) \
       .withColumn("source_file", F.lit("mock_policies.csv"))

# Write as Iceberg table to S3
df.writeTo("glue_catalog.insurance_landing.policies_raw") \
  .tableProperty("format-version", "2") \
  .createOrReplace()

print(f"Written {df.count()} rows to Iceberg landing table")
job.commit()