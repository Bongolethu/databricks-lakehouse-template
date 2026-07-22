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

# 1. ACCOUNT Provider (Pre-filled with your ID)
provider "databricks" {
  alias      = "accounts"
  host       = "https://accounts.gcp.databricks.com"
  account_id = "0015ba30-7a2a-469c-94cb-02579c15334a"
}

# 2. WORKSPACE Provider
provider "databricks" {
  alias = "workspace"
  host  = databricks_mws_workspaces.this.workspace_url
}
