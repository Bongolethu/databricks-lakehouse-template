# ------------------------------------------------------------------------------
# Databricks MWS Workspace Creation (GCP Example)
# ------------------------------------------------------------------------------
resource "databricks_mws_workspaces" "this" {
  provider       = databricks.mws
  account_id     = var.databricks_account_id
  workspace_name = var.workspace_name
  location       = var.google_region

  cloud_resource_container {
    gcp {
      project_id = var.google_project_id
    }
  }
}

# ------------------------------------------------------------------------------
# Example Workspace-Level Resources (Uses workspace provider)
# ------------------------------------------------------------------------------
resource "databricks_storage_credential" "external_storage_credential" {
  provider = databricks.workspace
  name     = "external_gcp_storage_credential"

  databricks_gcp_service_account {}

  depends_on = [databricks_mws_workspaces.this]
}

resource "google_storage_bucket_iam_member" "uc_bucket_access" {
  bucket = "${var.google_project_id}-lakehouse-data"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${databricks_storage_credential.external_storage_credential.databricks_gcp_service_account[0].email}"
}