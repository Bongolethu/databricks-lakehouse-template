terraform {
  required_version = ">= 1.0"

  # The GCS backend stores your state file safely in the cloud
  backend "gcs" {
    bucket = "bongo-143414.appspot.com"
    prefix = "terraform/state"
  }

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
}

# Google Cloud Provider
# In GitHub Actions, the 'auth' action handles the credentials automatically
provider "google" {
  project = var.gcp_project_id
  region  = "us-central1"
}

# Databricks Provider
provider "databricks" {
  host = var.databricks_workspace_host
  # Authentication is typically handled via Environment Variables in GitHub Actions
}
