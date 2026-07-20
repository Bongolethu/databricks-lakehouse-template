# ==========================================
# Google Cloud Storage Outputs
# ==========================================

output "gcs_lakehouse_bucket_name" {
  description = "The exact name of the GCS bucket created for lakehouse storage."
  value       = google_storage_bucket.lakehouse_bucket.name
}

output "gcs_lakehouse_bucket_url" {
  description = "The gs:// URI of the lakehouse bucket."
  value       = google_storage_bucket.lakehouse_bucket.url
}

# ==========================================
# Databricks Unity Catalog Outputs
# ==========================================

output "databricks_storage_credential_id" {
  description = "The ID of the storage credential used for Unity Catalog access."
  value       = databricks_storage_credential.external_storage_credential.id
}

output "bronze_external_location_url" {
  description = "The GCS path registered as an external location in Databricks."
  value       = databricks_external_location.bronze_external_location.url
}