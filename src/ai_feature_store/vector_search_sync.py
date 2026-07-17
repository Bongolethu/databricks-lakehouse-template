from databricks.vector_search.client import VectorSearchClient

def sync_vector_search_index():
    client = VectorSearchClient()
    
    # Target endpoints managed by the Solution Architect
    index_name = "main.gold.customer_knowledge_vector_index"
    endpoint_name = "claude-context-search-endpoint"
    
    print(f"Triggering synchronization loop for {index_name} on serverless compute...")
    index = client.get_index(endpoint_name=endpoint_name, index_name=index_name)
    
    # Sync operation respects row/column security filtering inside Unity Catalog automatically
    index.sync()
    print("Vector storage successfully matched with Gold Delta state layer.")

if __name__ == "__main__":
    sync_vector_search_index()