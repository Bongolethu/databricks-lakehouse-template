# ==============================================================================
# 1. Google Cloud Storage Bucket for Lakehouse Data
# ==============================================================================

resource "google_storage_bucket" "lakehouse_bucket" {
  name                     = "${var.gcp_project_id}-lakehouse-data"
  location                 = "US"
  force_destroy            = false
  public_access_prevention = "enforced"
}

# ==============================================================================
# 2. Databricks Unity Catalog Storage Credential & Locations
# ==============================================================================

resource "databricks_storage_credential" "external_storage_credential" {
  name = "gcp_lakehouse_storage_credential"

  databricks_gcp_service_account {}
}

resource "databricks_external_location" "bronze_external_location" {
  name            = "bronze_external_location"
  url             = "gs://${google_storage_bucket.lakehouse_bucket.name}/bronze"
  credential_name = databricks_storage_credential.external_storage_credential.name
}

resource "databricks_external_location" "silver_external_location" {
  name            = "silver_external_location"
  url             = "gs://${google_storage_bucket.lakehouse_bucket.name}/silver"
  credential_name = databricks_storage_credential.external_storage_credential.name
}

resource "databricks_external_location" "gold_external_location" {
  name            = "gold_external_location"
  url             = "gs://${google_storage_bucket.lakehouse_bucket.name}/gold"
  credential_name = databricks_storage_credential.external_storage_credential.name
}

# ==============================================================================
# 3. Medallion Architecture Catalogs & Schemas
# ==============================================================================

# --- Bronze Layer (Raw) ---
resource "databricks_catalog" "bronze" {
  name         = "bronze"
  comment      = "Bronze layer - Raw landing data"
  storage_root = databricks_external_location.bronze_external_location.url
}

resource "databricks_schema" "bronze_raw" {
  catalog_name = databricks_catalog.bronze.name
  name         = "raw"
}

# --- Silver Layer (Cleansed) ---
resource "databricks_catalog" "silver" {
  name         = "silver"
  comment      = "Silver layer - Cleansed and conformed data"
  storage_root = databricks_external_location.silver_external_location.url
}

resource "databricks_schema" "silver_cleansed" {
  catalog_name = databricks_catalog.silver.name
  name         = "cleansed"
}

# --- Gold Layer (Curated BI / Analytics) ---
resource "databricks_catalog" "gold" {
  name         = "gold"
  comment      = "Gold layer - Curated metrics and aggregates"
  storage_root = databricks_external_location.gold_external_location.url
}

resource "databricks_schema" "gold_analytics" {
  catalog_name = databricks_catalog.gold.name
  name         = "analytics"
}