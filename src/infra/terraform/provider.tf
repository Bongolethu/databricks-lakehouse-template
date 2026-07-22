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

data "google_client_config" "current" {}

provider "google" {
  project = "bongo-143414"
  region  = "us-central1"
}

provider "databricks" {
  alias      = "accounts"
  host       = "https://accounts.gcp.databricks.com"
  account_id = "YOUR_DATABRICKS_ACCOUNT_ID"
  token      = data.google_client_config.current.access_token
}

provider "databricks" {
  alias = "workspace"
  host  = databricks_mws_workspaces.this.workspace_url
  token = data.google_client_config.current.access_token
}
