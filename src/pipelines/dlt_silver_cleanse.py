import dlt
from pyspark.sql.functions import col, lower, trim

# Establish data quality expectations directly linked to the BA/TA Data Contract
rules_matrix = {
    "valid_id": "interaction_id IS NOT NULL",
    "valid_email": "email_address LIKE '%@%.%'"
}

@dlt.table(
    name="silver_customer_interactions",
    comment="Enriched, cleansed, and verified corporate interaction record layer."
)
@dlt.expect_all_or_drop(rules_matrix) # Instantly drops records violating the data contract
def silver_customer_interactions():
    return (
        dlt.read_stream("bronze_customer_interactions")
        .select(
            col("interaction_id").cast("string"),
            col("customer_id").cast("string"),
            trim(lower(col("email_address"))).alias("email_address"),
            col("raw_input_text").cast("string"),
            col("ingested_at")
        )
    )