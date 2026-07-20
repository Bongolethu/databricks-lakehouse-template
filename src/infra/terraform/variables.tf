variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "databricks_workspace_host" {
  type        = string
  description = "Databricks Workspace Host URL"
}

variable "databricks_uc_service_account" {
  type        = string
  description = "Databricks Unity Catalog Service Account Email"
}