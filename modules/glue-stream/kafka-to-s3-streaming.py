import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql import DataFrame, functions as F
from pyspark.sql.types import *

# Get job parameters
args = getResolvedOptions(sys.argv, [
    'JOB_NAME',
    'kafka-bootstrap-servers',
    's3-bucket-name'
])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Kafka configuration
kafka_bootstrap_servers = args['kafka_bootstrap_servers']
s3_bucket_name = args['s3_bucket_name']

# Define schema for transaction data
transaction_schema = StructType([
    StructField("transaction_id", StringType(), True),
    StructField("account_id", StringType(), True),
    StructField("transaction_type", StringType(), True),
    StructField("amount", LongType(), True),
    StructField("currency", StringType(), True),
    StructField("merchant_name", StringType(), True),
    StructField("category", StringType(), True),
    StructField("status", StringType(), True),
    StructField("balance_after", LongType(), True),
    StructField("location", StringType(), True),
    StructField("transaction_time", StringType(), True)
])

# Read from Kafka
kafka_df = spark \
    .readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", kafka_bootstrap_servers) \
    .option("subscribe", "transactions") \
    .option("startingOffsets", "earliest") \
    .option("failOnDataLoss", "false") \
    .load()

# Parse JSON and normalize location
parsed_df = kafka_df.select(
    F.from_json(F.col("value").cast("string"), transaction_schema).alias("data")
).select("data.*")

# Normalize location: add ", Vietnam" to location
normalized_df = parsed_df.withColumn(
    "location", 
    F.concat(F.col("location"), F.lit(", Vietnam"))
).withColumn(
    "transaction_date",
    F.to_date(F.col("transaction_time"))
)

# Write to S3 with partitioning by date and proper file naming
import time

def write_batch(batch_df, batch_id):
    if batch_df.count() > 0:
        run_id = int(time.time() * 1000)
        
        # Write to S3 with proper partitioning
        batch_df.coalesce(1) \
            .write \
            .mode("append") \
            .option("compression", "snappy") \
            .partitionBy("transaction_date") \
            .parquet("s3://prsv-vpb-hackathon-transaction-processed/")

query = normalized_df.writeStream \
    .foreachBatch(write_batch) \
    .option("checkpointLocation", f"s3://{s3_bucket_name}/checkpoints/kafka-streaming/") \
    .trigger(processingTime='1 minute') \
    .start()

query.awaitTermination()
job.commit()