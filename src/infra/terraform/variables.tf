variable "google_project_id" {
  type        = string
  description = "The GCP Project ID where resources will be created."
}

variable "google_region" {
  type        = string
  description = "GCP Region for deployment."
  default     = "us-central1"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID (from Account Console)."
}

variable "databricks_client_id" {
  type        = string
  description = "Service Principal Client ID with Account Admin rights."
  sensitive   = true
}

variable "databricks_client_secret" {
  type        = string
  description = "Service Principal Secret."
  sensitive   = true
}

variable "workspace_name" {
  type        = string
  description = "Name of the Databricks Workspace to create."
  default     = "lakehouse-workspace"
}