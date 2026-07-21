terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.30"
    }
  }
}

# ------------------------------------------------------------------------------
# 1. Google Cloud Storage Bucket for Lakehouse Data
# ------------------------------------------------------------------------------
resource "google_storage_bucket" "lakehouse_bucket" {
  name                        = "${var.prefix}-lakehouse-data"
  location                    = var.gcp_region
  force_destroy               = true
  uniform_bucket_level_access = true

  public_access_prevention = "enforced"
}

# ------------------------------------------------------------------------------
# 2. Databricks Storage Credential using GCP Workload Identity Federation
# ------------------------------------------------------------------------------
resource "databricks_storage_credential" "external_storage_credential" {
  name            = "${var.prefix}-storage-cred"
  skip_validation = true # Allows creation before GCP IAM roles are granted

  # Enables Databricks-managed GCP Workload Identity Federation
  databricks_gcp_service_account {}

  comment = "Storage credential using GCP Workload Identity Federation"
}

# ------------------------------------------------------------------------------
# 3. Grant Databricks System Service Account Access to GCS Bucket
# ------------------------------------------------------------------------------
resource "google_storage_bucket_iam_member" "uc_bucket_admin" {
  bucket = google_storage_bucket.lakehouse_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${databricks_storage_credential.external_storage_credential.databricks_gcp_service_account[0].email}"
}

# ------------------------------------------------------------------------------
# 4. Databricks External Location
# ------------------------------------------------------------------------------
resource "databricks_external_location" "external_location" {
  name            = "${var.prefix}-external-location"
  url             = google_storage_bucket.lakehouse_bucket.url
  credential_name = databricks_storage_credential.external_storage_credential.name
  comment         = "External location pointing to Lakehouse GCS bucket"

  depends_on = [
    google_storage_bucket_iam_member.uc_bucket_admin
  ]
}

# ------------------------------------------------------------------------------
# 5. Unity Catalog Catalogs (Bronze, Silver, Gold)
# ------------------------------------------------------------------------------
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