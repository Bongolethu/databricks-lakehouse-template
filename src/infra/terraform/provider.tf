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
      version = ">= 1.0"
    }
  }

  backend "gcs" {
    bucket = "bongo-143414-tfstate"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = "bongo-143414"
  region  = "us-central1"
}

# 1. Databricks ACCOUNT Provider (HARDCODED)
provider "databricks" {
  alias         = "accounts"
  host          = "https://accounts.gcp.databricks.com"
  # PASTE YOUR ACTUAL VALUES HERE:
  account_id    = "PASTE_YOUR_DATABRICKS_ACCOUNT_ID_HERE"
  client_id     = "PASTE_YOUR_DATABRICKS_APPLICATION_ID_HERE"
  client_secret = "PASTE_YOUR_DATABRICKS_SECRET_HERE"
}

# 2. Databricks WORKSPACE Provider (HARDCODED)
provider "databricks" {
  alias         = "workspace"
  host          = databricks_mws_workspaces.this.workspace_url
  # PASTE YOUR ACTUAL VALUES HERE:
  client_id     = "PASTE_YOUR_DATABRICKS_APPLICATION_ID_HERE"
  client_secret = "PASTE_YOUR_DATABRICKS_SECRET_HERE"
}
