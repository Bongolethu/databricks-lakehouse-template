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

# 2. Force the Databricks ACCOUNT Provider to use your Google Cloud token
provider "databricks" {
  alias      = "accounts"
  host       = "https://accounts.gcp.databricks.com"
  account_id = var.databricks_account_id
  token      = data.google_client_config.current.access_token
}

# 3. Force the Databricks WORKSPACE Provider to use your Google Cloud token
provider "databricks" {
  alias = "workspace"
  host  = databricks_mws_workspaces.this.workspace_url
  token = data.google_client_config.current.access_token
}
