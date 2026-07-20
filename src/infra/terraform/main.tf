# ==============================================================================
# 1. Storage Bucket for Lakehouse Data
# ==============================================================================

resource "google_storage_bucket" "lakehouse_bucket" {
  name                     = "${var.gcp_project_id}-lakehouse-data"
  location                 = "US"
  force_destroy            = false
  public_access_prevention = "enforced"
}

# Automatically imports the existing bucket into Terraform state to resolve 409 conflict
import {
  to = google_storage_bucket.lakehouse_bucket
  id = "${var.gcp_project_id}-lakehouse-data"
}

# ==============================================================================
# 2. Medallion Catalogs & Schemas
# ==============================================================================

# --- Bronze Layer ---
resource "databricks_catalog" "bronze" {
  name    = "bronze"
  comment = "Bronze catalog for raw ingested data"
}

resource "databricks_schema" "bronze_raw" {
  catalog_name = databricks_catalog.bronze.name
  name         = "raw"
}

# --- Silver Layer ---
resource "databricks_catalog" "silver" {
  name    = "silver"
  comment = "Silver catalog for cleansed and conformed data"
}

resource "databricks_schema" "silver_cleansed" {
  catalog_name = databricks_catalog.silver.name
  name         = "cleansed"
}

# --- Gold Layer ---
resource "databricks_catalog" "gold" {
  name    = "gold"
  comment = "Gold catalog for analytics and reporting"
}

resource "databricks_schema" "gold_analytics" {
  catalog_name = databricks_catalog.gold.name
  name         = "analytics"
}