from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import DoubleType

spark = SparkSession.builder \
    .appName("InsuranceLanding_to_IDL") \
    .config("spark.sql.catalog.glue_catalog", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.glue_catalog.warehouse", "s3://insurance-lakehouse-demo-2026/") \
    .config("spark.sql.catalog.glue_catalog.catalog-impl", "org.apache.iceberg.aws.glue.GlueCatalog") \
    .config("spark.sql.catalog.glue_catalog.io-impl", "org.apache.iceberg.aws.s3.S3FileIO") \
    .getOrCreate()

# READ from landing Iceberg table
landing_df = spark.read \
    .format("iceberg") \
    .load("glue_catalog.insurance_landing.policies_raw")

print(f"Landing row count: {landing_df.count()}")

# ── DATA QUALITY CHECKS ──────────────────────────────
# 1. Drop rows with null policy_id (PK must exist)
clean_df = landing_df.filter(F.col("policy_id").isNotNull())

# 2. Standardize policy_status to uppercase
clean_df = clean_df.withColumn("policy_status", F.upper(F.col("policy_status")))

# 3. Flag premium outliers (Data Profiling concept)
premium_stats = clean_df.agg(
    F.mean("premium_amount").alias("mean"),
    F.stddev("premium_amount").alias("stddev")
).collect()[0]

clean_df = clean_df.withColumn(
    "is_premium_outlier",
    F.when(
        F.abs(F.col("premium_amount") - premium_stats["mean"]) > 3 * premium_stats["stddev"],
        True
    ).otherwise(False)
)

# 4. Add derived business columns (IDL enrichment)
clean_df = clean_df.withColumn(
    "annual_premium",
    (F.col("premium_amount") * 12).cast(DoubleType())
).withColumn(
    "coverage_to_premium_ratio",
    F.round(F.col("coverage_amount") / F.col("premium_amount"), 2)
).withColumn(
    "idl_processed_at", F.current_timestamp()
)

# ── WRITE to IDL Iceberg table ───────────────────────
clean_df.writeTo("glue_catalog.insurance_landing.policies_idl") \
    .tableProperty("format-version", "2") \
    .tableProperty("write.target-file-size-bytes", "134217728") \
    .createOrReplace()

print(f"IDL row count: {clean_df.count()}")

# ── TIME TRAVEL DEMO (Iceberg superpower) ────────────
# Check table history
spark.sql("SELECT * FROM glue_catalog.insurance_landing.policies_idl.history").show()