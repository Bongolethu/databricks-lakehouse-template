import os
import pytest
from databricks import sql

@pytest.fixture
def sql_connection():
    # Establishes connection to the Serverless SQL Warehouse
    return sql.connect(
        server_hostname=os.environ.get("DATABRICKS_HOST").replace("https://", ""),
        http_path="/sql/1.0/warehouses/gold_semantic_warehouse",
        access_token=os.environ.get("DATABRICKS_TOKEN")
    )

def test_pii_masking_enforcement_on_gold_layer(sql_connection):
    """
    Verifies that querying the customer interaction layer applies mask functions correctly.
    """
    cursor = sql_connection.cursor()
    
    # Execute query against active gold tracking asset fields
    cursor.execute("SELECT email_address FROM main.silver.silver_customer_interactions LIMIT 5")
    results = cursor.fetchall()
    
    for row in results:
        email = row[0]
        # Assert that if the running pipeline is not an elevated admin persona, 
        # the middle section of the email has been redacted with asterisks.
        if email is not None:
            assert "*" in email, f"Security Breach! Raw PII email string leaked: {email}"
            
    cursor.close()
    sql_connection.close()