terraform {
  required_version = ">= 1.5.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    # Backend configuration passed via backend config or pipeline
  }
}

# 1. Primary / Default Databricks Provider (Workspace level)
provider "databricks" {
  host          = var.databricks_host
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
}

# 2. MWS / Account-Level Databricks Provider (Aliased)
provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.gcp.databricks.com"
  account_id    = var.databricks_account_id
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
}

# 3. Google Cloud Provider
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}