import dlt
from pyspark.sql.functions import count, col

@dlt.table(
    name="gold_interaction_summaries",
    comment="Aggregated, production star-schema assets optimized for PowerBI and Claude RAG queries.",
    table_properties={"delta.enableLiquidClustering": "true"} # Dynamic indexing replaces rigid partitions
)
# Specify the clustering keys managed by the Technical Analyst configuration profiles
@dlt.cluster_by(["customer_id"])
def gold_interaction_summaries():
    return (
        dlt.read("silver_customer_interactions")
        .groupBy("customer_id")
        .agg(
            count("interaction_id").alias("total_interactions_logged")
        )
    )