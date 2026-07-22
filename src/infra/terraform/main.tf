#main.t
# ==============================================================================
# GOOGLE CLOUD NETWORKING
# ==============================================================================
resource "google_compute_network" "databricks_vpc" {
  name                    = "databricks-vpc"
  auto_create_subnetworks = false
  project                 = var.gcp_project_id
}

resource "google_compute_subnetwork" "databricks_subnet" {
  name                     = "databricks-subnet"
  ip_cidr_range            = "10.0.0.0/20"
  network                  = google_compute_network.databricks_vpc.id
  region                   = var.gcp_region
  project                  = var.gcp_project_id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "databricks-pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "databricks-services"
    ip_cidr_range = "10.2.0.0/20"
  }
}

resource "google_compute_router" "databricks_router" {
  name    = "databricks-router"
  region  = var.gcp_region
  network = google_compute_network.databricks_vpc.id
  project = var.gcp_project_id
}

resource "google_compute_router_nat" "databricks_nat" {
  name                               = "databricks-nat"
  router                             = google_compute_router.databricks_router.name
  region                             = var.gcp_region
  project                            = var.gcp_project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# ==============================================================================
# STORAGE BUCKETS
# ==============================================================================
resource "google_storage_bucket" "lakehouse_bucket" {
  name                        = "${var.gcp_project_id}-lakehouse-data"
  location                    = var.gcp_region
  project                     = var.gcp_project_id
  force_destroy               = true
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

# ==============================================================================
# DATABRICKS WORKSPACE & UNITY CATALOG
# ==============================================================================
resource "google_service_account" "databricks_sa" {
  account_id   = "databricks-deployer-sa"
  display_name = "Databricks Deployer Service Account"
  project      = var.gcp_project_id
}

resource "databricks_mws_workspaces" "this" {
  provider       = databricks.accounts
  account_id     = var.databricks_account_id
  workspace_name = var.workspace_name
  location       = var.gcp_region
  cloud          = "gcp"

  cloud_resource_container {
    gcp {
      project_id = var.gcp_project_id
    }
  }

  depends_on = [
    google_service_account.databricks_sa
  ]
}

resource "databricks_storage_credential" "external_storage_credential" {
  provider = databricks.workspace
  name     = "external_gcp_storage_credential"
  databricks_gcp_service_account {}
  depends_on = [
    databricks_mws_workspaces.this
  ]
}

resource "google_storage_bucket_iam_member" "uc_bucket_access" {
  bucket = google_storage_bucket.lakehouse_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${databricks_storage_credential.external_storage_credential.databricks_gcp_service_account[0].email}"
}

# ==============================================================================
# CATALOGS
# ==============================================================================
resource "databricks_catalog" "bronze" {
  provider = databricks.workspace
  name     = "bronze"
}
resource "databricks_catalog" "silver" {
  provider = databricks.workspace
  name     = "silver"
}
resource "databricks_catalog" "gold" {
  provider = databricks.workspace
  name     = "gold"
}
