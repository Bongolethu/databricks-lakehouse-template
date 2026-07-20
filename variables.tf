variable "gcp_project_id" {
  type        = string
  description = "The Google Cloud Project ID"
}

variable "databricks_workspace_host" {
  type        = string
  description = "The Databricks workspace URL"
}

variable "databricks_uc_service_account" {
  type        = string
  description = "The service account used for Databricks Unity Catalog"
}
