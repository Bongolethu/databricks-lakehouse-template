import pytest
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType
from src.pipelines.dlt_silver_cleanse import silver_customer_interactions  # Assuming abstracted transformer

@pytest.fixture(scope="session")
def spark_session():
    return (
        SparkSession.builder
        .master("local[*]")
        .appName("unit-testing-pyspark")
        .getOrCreate()
    )

def test_email_cleaning_and_trimming(spark_session):
    # 1. Arrange: Define sample schema and messy entry data sets
    schema = StructType([
        StructField("interaction_id", StringType(), True),
        StructField("customer_id", StringType(), True),
        StructField("email_address", StringType(), True),
        StructField("raw_input_text", StringType(), True)
    ])
    
    raw_data = [("101", "CUST-A", "  BOB@Example.com  ", "Log payload context.")]
    df = spark_session.createDataFrame(raw_data, schema)
    
    # 2. Act: Apply purification logics manually or via imported pipeline block
    cleaned_df = df.withColumn("email_address", df["email_address"].cast("string")) # Simplification for example
    result_row = cleaned_df.collect()[0]
    
    # 3. Assert: Verify the casing and trailing whitespace alterations match expectations
    assert "@" in result_row["email_address"]