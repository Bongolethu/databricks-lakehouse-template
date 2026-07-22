# variables.tf
variable "gcp_project_id" {
  type        = string
  default     = "bongo-143414"
  description = "The Google Cloud Project ID"
}

variable "gcp_region" {
  type        = string
  default     = "us-central1"
  description = "The Google Cloud Region"
}

variable "databricks_account_id" {
  type        = string
  description = "Your Databricks Account ID"
  sensitive   = true
}

variable "workspace_name" {
  type        = string
  default     = "bongo-db-workspace"
  description = "The name of the Databricks workspace"
}

variable "databricks_client_id" {
  type        = string
  description = "Databricks OAuth Client ID"
  sensitive   = true
}

variable "databricks_client_secret" {
  type        = string
  description = "Databricks OAuth Client Secret"
  sensitive   = true
}
