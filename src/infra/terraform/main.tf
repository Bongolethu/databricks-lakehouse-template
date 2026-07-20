# ==============================================================================
# 1. Storage Bucket for Lakehouse Data
# ==============================================================================

resource "google_storage_bucket" "lakehouse_bucket" {
  name                     = "${var.gcp_project_id}-lakehouse-data"
  location                 = "US"
  force_destroy            = false
  public_access_prevention = "enforced"
}

# Automatically imports existing bucket to resolve 409 conflict
import {
  to = google_storage_bucket.lakehouse_bucket
  id = "${var.gcp_project_id}-lakehouse-data"
}

# ==============================================================================
# 2. Storage Credential & Root External Location
# ==============================================================================

resource "databricks_storage_credential" "external_storage_credential" {
  name = "gcp_lakehouse_storage_credential"

  databricks_gcp_service_account {}
}

resource "databricks_external_location" "lakehouse_external_location" {
  name            = "lakehouse_external_location"
  url             = "${google_storage_bucket.lakehouse_bucket.url}/"
  credential_name = databricks_storage_credential.external_storage_credential.name
  comment         = "Root external location covering gs://${var.gcp_project_id}-lakehouse-data/"
  force_destroy   = true
}

# ==============================================================================
# 3. Medallion Catalogs & Schemas
# ==============================================================================

# --- Bronze Layer ---
resource "databricks_catalog" "bronze" {
  name         = "bronze"
  comment      = "Bronze catalog for raw ingested data"
  storage_root = "${databricks_external_location.lakehouse_external_location.url}bronze"
}

resource "databricks_schema" "bronze_raw" {
  catalog_name = databricks_catalog.bronze.name
  name         = "raw"
}

# --- Silver Layer ---
resource "databricks_catalog" "silver" {
  name         = "silver"
  comment      = "Silver catalog for cleansed and conformed data"
  storage_root = "${databricks_external_location.lakehouse_external_location.url}silver"
}

resource "databricks_schema" "silver_cleansed" {
  catalog_name = databricks_catalog.silver.name
  name         = "cleansed"
}

# --- Gold Layer ---
resource "databricks_catalog" "gold" {
  name         = "gold"
  comment      = "Gold catalog for analytics and reporting"
  storage_root = "${databricks_external_location.lakehouse_external_location.url}gold"
}

resource "databricks_schema" "gold_analytics" {
  catalog_name = databricks_catalog.gold.name
  name         = "analytics"
}