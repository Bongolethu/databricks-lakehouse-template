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
  account_id    = "0015ba30-7a2a-469c-94cb-02579c15334a"
  client_id     = "d03b0302-4a41-4be6-80cd-b1528226c26b"
  client_secret = "doseacbfff4fd46e7766afd21d644ae95b90"
}

# 2. Databricks WORKSPACE Provider (HARDCODED)
provider "databricks" {
  alias         = "workspace"
  host          = databricks_mws_workspaces.this.workspace_url
  # PASTE YOUR ACTUAL VALUES HERE: 
  client_id     = "ed1496a8-d9ab-4e2b-b67e-60a3da484d3f"
  client_secret = "dose73ea3aaf5377ef781014c3576b31e10b"
}
