variable "gcp_project_id" {
  type        = string
  description = "Google Cloud Project ID"
}

variable "gcp_region" {
  type        = string
  description = "GCP Region"
  default     = "us-central1"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "databricks_host" {
  type        = string
  description = "Databricks Workspace URL"
}

variable "databricks_client_id" {
  type        = string
  description = "Databricks Service Principal Client ID"
  sensitive   = true
}

variable "databricks_client_secret" {
  type        = string
  description = "Databricks Service Principal Client Secret"
  sensitive   = true
}