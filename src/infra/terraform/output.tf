output "gcs_lakehouse_bucket_name" {
  description = "GCS Bucket name hosting the lakehouse data"
  value       = google_storage_bucket.lakehouse_bucket.name
}

output "gcs_lakehouse_bucket_url" {
  description = "GCS Bucket URL"
  value       = google_storage_bucket.lakehouse_bucket.url
}

output "databricks_storage_credential_id" {
  description = "Databricks Storage Credential ID"
  value       = databricks_storage_credential.external_storage_credential.id
}

output "bronze_external_location_url" {
  description = "Bronze layer external location URL"
  value       = databricks_external_location.bronze_external_location.url
}