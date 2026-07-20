variable "gcp_project_id" {
  type        = string
  description = "The Google Cloud Project ID"
}

variable "databricks_workspace_host" {
  type        = string
  description = "Databricks Workspace Host URL"
  # DO NOT put default = "https://..." here!
}

variable "databricks_uc_service_account" {
  type        = string
  description = "The service account used for Databricks Unity Catalog"
}
