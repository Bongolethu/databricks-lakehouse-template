import os
import pytest
from databricks.sdk import WorkspaceClient

@pytest.fixture
def workspace_client():
    return WorkspaceClient(
        host=os.environ.get("DATABRICKS_HOST"),
        token=os.environ.get("DATABRICKS_TOKEN")
    )

def test_pipeline_expectations_metric_thresholds(workspace_client):
    """
    Validates that the percentage of dropped bad records doesn't exceed 5% of total ingest volume.
    """
    pipeline_name = "Customer_Interactions_DLT_Engine"
    
    # 1. Pull execution events from the Databricks environment
    all_pipelines = workspace_client.pipelines.list_pipelines()
    target_pipeline = next(p for p in all_pipelines if p.name == pipeline_name)
    
    events = workspace_client.pipelines.list_pipeline_events(pipeline_id=target_pipeline.pipeline_id)
    
    # 2. Extract telemetry tracking information metrics
    for event in events:
        if event.event_type == "flow_progress":
            metrics = event.details.get("flow_progress", {}).get("metrics", {})
            dropped_records = metrics.get("num_dropped_records", 0)
            output_records = metrics.get("num_output_records", 0)
            
            if output_records > 0:
                failure_rate = dropped_records / (dropped_records + output_records)
                # Fail test if structural data quality is drifting significantly
                assert failure_rate < 0.05, f"Data contract breach! Pipeline dropping {failure_rate:.2%} of rows."