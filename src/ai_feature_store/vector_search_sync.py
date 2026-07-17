# filepath: src/ai_feature_store/vector_search_sync.py
import os
import time
from databricks.sdk import WorkspaceClient
from databricks.vector_search.client import VectorSearchClient

def sync_vector_search_index():
    """
    Production script to safely authenticate and synchronize a Databricks Delta table
    with a serverless Mosaic AI Vector Search index while resolving external dependencies via Secrets.
    """
    print("Initializing Databricks Workspace Client...")
    # The WorkspaceClient automatically picks up ambient credentials (OIDC / Managed Identity)
    # provisioned during the GitHub Actions deployment execution loop.
    w = WorkspaceClient()

    # 1. Fetch Third-Party AI Engine Credentials Safely from Vault Storage
    # Prevents exposing critical security profiles in clear text within environment states
    try:
        print("Fetching third-party AI keys from encrypted Databricks Secret Scope...")
        anthropic_key = w.secrets.get(scope="ai_credentials", key="anthropic_api_key")
        # Inject securely into the ambient framework context for the application session if needed
        os.environ["ANTHROPIC_API_KEY"] = anthropic_key.value
        print("Successfully injected Anthropic API key into runtime context.")
    except Exception as e:
        print(f"CRITICAL: Failed to retrieve keys from Databricks Secret Scope. Error: {str(e)}")
        raise e

    # 2. Establish Mosaic AI Vector Search Connection Contexts
    # These names align exactly with resources declared in infra/resources/jobs.yml
    endpoint_name = "claude-context-search-endpoint"
    index_name = "main.gold.customer_knowledge_vector_index"

    print(f"Connecting to Vector Search Client Endpoint: {endpoint_name}...")
    vsc = VectorSearchClient()

    try:
        index = vsc.get_index(endpoint_name=endpoint_name, index_name=index_name)
        print(f"Successfully connected to vector index: {index_name}")

        # 3. Trigger Synchronous Optimization Execution
        print("Triggering synchronization loop for serverless pipeline compute...")
        index.sync()
        print("Sync command transmitted successfully. Awaiting data state convergence...")

        # 4. Optional: Enterprise polling mechanism to confirm indexing completion before task exit
        # This prevents downstream evaluation stages from reading stale data states.
        for attempt in range(12):  # Poll for up to 2 minutes
            status = index.describe()
            status_state = status.get("status", {}).get("state", "UNKNOWN")
            print(f"Current Index Synchronization State: {status_state}")
            
            if status_state == "ONLINE":
                print("Vector storage successfully matched with Gold Delta state layer.")
                break
            elif status_state in ["FAILED", "PROVISIONING_ERROR"]:
                raise RuntimeError(f"Vector search sync failed with state: {status_state}")
                
            time.sleep(10)
        else:
            print("WARNING: Sync timeout reached. Index is still processing in background.")

    except Exception as e:
        print(f"CRITICAL: Vector Search index synchronization routine aborted. Error: {str(e)}")
        raise e

if __name__ == "__main__":
    sync_vector_search_index()