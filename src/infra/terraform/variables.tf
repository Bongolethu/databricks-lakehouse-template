# ==============================================================================
# GCP CONFIGURATION
# ==============================================================================
variable "gcp_project_id" {
  type        = string
  description = "The Google Cloud Project ID"
  default     = "bongo-143414"
}

variable "gcp_region" {
  type        = string
  description = "The Google Cloud Region"
  default     = "us-central1"
}

# ==============================================================================
# DATABRICKS WORKSPACE & ACCOUNT CONFIGURATION
# ==============================================================================
variable "databricks_account_id" {
  type        = string
  description = "Your Databricks Account ID"
  sensitive   = true
}

variable "workspace_name" {
  type        = string
  description = "The name of the Databricks workspace"
  default     = "bongo-db-workspace"
}

variable "databricks_host" {
  type        = string
  description = "Databricks Workspace host URL"
  default     = ""
}

# ==============================================================================
# DATABRICKS AUTHENTICATION
# ==============================================================================
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