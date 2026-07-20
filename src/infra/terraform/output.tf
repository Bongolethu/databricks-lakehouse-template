# ==============================================================================
# GCS Storage Outputs
# ==============================================================================

output "lakehouse_bucket_name" {
  description = "The name of the GCS bucket created for the lakehouse"
  value       = google_storage_bucket.lakehouse_bucket.name
}

output "lakehouse_bucket_url" {
  description = "The gs:// URL of the GCS bucket"
  value       = google_storage_bucket.lakehouse_bucket.url
}

# ==============================================================================
# Databricks Medallion Catalog Outputs
# ==============================================================================

output "bronze_catalog_id" {
  description = "The ID of the Bronze catalog"
  value       = databricks_catalog.bronze.id
}

output "silver_catalog_id" {
  description = "The ID of the Silver catalog"
  value       = databricks_catalog.silver.id
}

output "gold_catalog_id" {
  description = "The ID of the Gold catalog"
  value       = databricks_catalog.gold.id
}