# provider.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.0"
    }
  }

  backend "gcs" {
    bucket = "bongo-143414-tfstate"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# 1. Fetch your active Google Cloud OAuth token
data "google_client_config" "current" {}

# 2  Provider for Account-level resources (mws_workspaces)
provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.gcp.databricks.com" # or accounts.cloud.databricks.com / accounts.azuredatabricks.net
  account_id    = var.databricks_account_id
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
}
# Provider for Account-level resources (mws_workspaces)
provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.gcp.databricks.com" # or accounts.cloud.databricks.com / accounts.azuredatabricks.net
  account_id    = var.databricks_account_id
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
}

# 3. Force the Databricks WORKSPACE Provider to use your Google Cloud token
provider "databricks" {
  alias = "workspace"
  host  = databricks_mws_workspaces.this.workspace_url
  token = data.google_client_config.current.access_token
}
