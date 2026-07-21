# main.tf — Remove terraform/required_providers from here

resource "google_storage_bucket" "lakehouse_bucket" {
  name                        = "${var.prefix}-lakehouse-data"
  location                    = var.gcp_region
  force_destroy               = true
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

resource "databricks_storage_credential" "external_storage_credential" {
  name            = "${var.prefix}-storage-cred"
  skip_validation = true

  databricks_gcp_service_account {}

  comment = "Storage credential using GCP Workload Identity Federation"
}

resource "google_storage_bucket_iam_member" "uc_bucket_admin" {
  bucket = google_storage_bucket.lakehouse_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${databricks_storage_credential.external_storage_credential.databricks_gcp_service_account[0].email}"
}

resource "databricks_external_location" "external_location" {
  name            = "${var.prefix}-external-location"
  url             = google_storage_bucket.lakehouse_bucket.url
  credential_name = databricks_storage_credential.external_storage_credential.name
  comment         = "External location pointing to Lakehouse GCS bucket"

  depends_on = [google_storage_bucket_iam_member.uc_bucket_admin]
}

resource "databricks_catalog" "bronze" {
  name          = "${var.prefix}_bronze"
  comment       = "Bronze tier catalog"
  storage_root  = "${google_storage_bucket.lakehouse_bucket.url}/bronze"
  force_destroy = true

  depends_on = [databricks_external_location.external_location]
}

resource "databricks_catalog" "silver" {
  name          = "${var.prefix}_silver"
  comment       = "Silver tier catalog"
  storage_root  = "${google_storage_bucket.lakehouse_bucket.url}/silver"
  force_destroy = true

  depends_on = [databricks_external_location.external_location]
}

resource "databricks_catalog" "gold" {
  name          = "${var.prefix}_gold"
  comment       = "Gold tier catalog"
  storage_root  = "${google_storage_bucket.lakehouse_bucket.url}/gold"
  force_destroy = true

  depends_on = [databricks_external_location.external_location]
}