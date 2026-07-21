terraform {
  required_version = ">= 1.5.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.30"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# ------------------------------------------------------------------------------
# Provider for GCP
# ------------------------------------------------------------------------------
provider "google" {
  project = var.google_project_id
  region  = var.google_region
}

# ------------------------------------------------------------------------------
# Databricks Account-Level Provider (Used for MWS Workspace creation)
# ------------------------------------------------------------------------------
provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.gcp.databricks.com"
  account_id    = var.databricks_account_id
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
}

# ------------------------------------------------------------------------------
# Databricks Workspace-Level Provider (Used AFTER the workspace is deployed)
# ------------------------------------------------------------------------------
provider "databricks" {
  alias         = "workspace"
  host          = databricks_mws_workspaces.this.workspace_url
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
}