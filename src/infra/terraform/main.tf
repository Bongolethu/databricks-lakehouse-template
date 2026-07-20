# ==========================================
# 1. TERRAFORM & PROVIDERS CONFIGURATION
# ==========================================
terraform {
  required_version = ">= 1.5.0"
  
  # Add this block to save your state file in GCP
  backend "gcs" {
    bucket  = " bongo-143414.appspot.com"
    prefix  = "terraform/state"
  }
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.20"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# The Databricks provider handles workspace-level object configurations
provider "databricks" {
  host = var.databricks_workspace_host
}

# ==========================================
# 2. INPUT VARIABLES
# ==========================================
variable "gcp_project_id" {
  type        = string
  description = "The alphanumeric Google Cloud Project ID."
}

variable "gcp_region" {
  type        = string
  default     = "us-central1"
  description = "The targeted Google Cloud region for infrastructure deployment."
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Deployment environment stage tag (e.g., dev, prod)."
}

variable "databricks_workspace_host" {
  type        = string
  description = "The specific Databricks workspace URL (e.g., https://12345.gcp.databricks.com)."
}

variable "databricks_uc_service_account" {
  type        = string
  description = "The IAM Service Account email used by Unity Catalog to access GCS buckets."
}

# ==========================================
# 3. SECURE INFRASTRUCTURE (GCS Storage Bucket)
# ==========================================
resource "google_storage_bucket" "lakehouse_bucket" {
  name                        = "enterprise-dl-lakehouse-${var.environment}-${var.gcp_project_id}"
  location                    = upper(var.gcp_region)
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = var.environment == "dev" ? true : false

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }
}

# ==========================================
# 4. DATABRICKS UNITY CATALOG GOVERNANCE
# ==========================================

# Establishes the trusted data execution identity inside the metastore
resource "databricks_storage_credential" "external_storage_credential" {
  name = "gcp_lakehouse_execution_credential"
  
  gcp_service_account {
    email = var.databricks_uc_service_account
  }
  
  comment = "Delegated service identity utilized by Unity Catalog to interact with GCS."
}

# Declares the root isolation boundary for raw landing data
resource "databricks_external_location" "bronze_external_location" {
  name            = "${var.environment}_bronze_raw_landing"
  url             = "gs://${google_storage_bucket.lakehouse_bucket.name}/bronze"
  credential_name = databricks_storage_credential.external_storage_credential.name
  comment         = "Isolates the raw landing data entry zone boundary within Google Cloud Storage."
}

# ==========================================
# 5. OUTPUTS
# ==========================================
output "gcs_bucket_name" {
  value       = google_storage_bucket.lakehouse_bucket.name
  description = "The generated Google Cloud Storage bucket path name."
}

output "external_location_url" {
  value       = databricks_external_location.bronze_external_location.url
  description = "The verified external data path registered within Databricks Unity Catalog."
}