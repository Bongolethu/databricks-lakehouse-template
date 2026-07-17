import dlt
from pyspark.sql.functions import current_timestamp

@dlt.table(
    name="bronze_customer_interactions",
    comment="Raw streaming ingestion zone for incoming customer profiles and chat text transcripts."
)
def bronze_customer_interactions():
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", "json")
        .option("cloudFiles.inferColumnTypes", "true")
        .load("dbfs:/mnt/incoming-raw-source/interactions/")
        .withColumn("ingested_at", current_timestamp())
    )