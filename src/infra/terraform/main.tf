# main.tf

# ==============================================================================
# GOOGLE CLOUD NETWORKING (Customer-Managed VPC for GKE)
# ==============================================================================

# Custom VPC Network
resource "google_compute_network" "databricks_vpc" {
  name                    = "databricks-vpc"
  auto_create_subnetworks = false
  project                 = var.gcp_project_id
}

# Subnetwork with GKE Secondary Ranges for Databricks Compute Nodes
resource "google_compute_subnetwork" "databricks_subnet" {
  name                     = "databricks-subnet"
  ip_cidr_range            = "10.0.0.0/20" # Primary Node range
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

# Cloud Router (for NAT)
resource "google_compute_router" "databricks_router" {
  name    = "databricks-router"
  region  = var.gcp_region
  network = google_compute_network.databricks_vpc.id
  project = var.gcp_project_id
}

# Cloud NAT Gateway for secure outbound internet egress (without public IPs)
resource "google_compute_router_nat" "databricks_nat" {
  name                               = "databricks-nat"
  router                             = google_compute_router.databricks_router.name
  region                             = var.gcp_region
  project                            = var.gcp_project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# ==============================================================================
# STORAGE BUCKETS (Lakehouse Data)
# ==============================================================================

# GCS Bucket for Lakehouse Data (Unity Catalog)
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
# IAM & IDENTITY (Workspace & Unity Catalog Service Accounts)
# ==============================================================================

# 1. Workspace Cluster Deployer Service Account
resource "google_service_account" "databricks_sa" {
  account_id   = "databricks-deployer-sa"
  display_name = "Databricks Deployer Service Account"
  project      = var.gcp_project_id
}

# Grant Project Roles for Cluster Management (GKE, VM management)
resource "google_project_iam_member" "databricks_project_roles" {
  for_each = toset([
    "roles/compute.admin",
    "roles/container.admin",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountTokenCreator"
  ])
  project = var.gcp_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.databricks_sa.email}"
}

# 2. Unity Catalog Service Account
resource "google_service_account" "databricks_uc_sa" {
  account_id   = "databricks-uc-sa"
  display_name = "Databricks Unity Catalog Service Account"
  project      = var.gcp_project_id
}

# Grant Object Admin on Lakehouse Bucket to Unity Catalog Service Account
resource "google_storage_bucket_iam_member" "uc_bucket_access" {
  bucket = google_storage_bucket.lakehouse_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.databricks_uc_sa.email}"
}

# Allow Databricks system identity to impersonate our local UC Service Account
# (Solves: "Gcp Workload Identity Federation is not enabled" error)
resource "google_service_account_iam_member" "databricks_uc_impersonation" {
  service_account_id = google_service_account.databricks_uc_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:gcp-unity-catalog@databricks-prod-gcp.iam.gserviceaccount.com"
}

# ==============================================================================
# WORKLOAD IDENTITY FEDERATION (For GitHub Actions Deployments)
# ==============================================================================

# Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"
  project                   = var.gcp_project_id
}

# Provider
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  project                            = var.gcp_project_id

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# ==============================================================================
# DATABRICKS WORKSPACE & UNITY CATALOG CREDENTIALS
# ==============================================================================

# Create Databricks Workspace (Uses Accounts Provider)
resource "databricks_mws_workspaces" "this" {
  provider       = databricks.accounts
  account_id     = var.databricks_account_id
  workspace_name = var.workspace_name
  location       = var.gcp_region
  cloud          = "gcp"

  # Correct syntax for GCP deployments: Databricks manages the DBFS storage container automatically
  cloud_resource_container {
    gcp {
      project_id = var.gcp_project_id
    }
  }

  depends_on = [
    google_project_iam_member.databricks_project_roles
  ]
}

# Create Storage Credential in Unity Catalog (Uses Workspace Provider)
# (Solves: "failed to validate workspace_id: Invalid access token" error)
resource "databricks_storage_credential" "external_storage_credential" {
  provider = databricks.workspace
  name     = "external_gcp_storage_credential"

  gcp_service_account {
    email = google_service_account.databricks_uc_sa.email
  }

  depends_on = [
    databricks_mws_workspaces.this,
    google_service_account_iam_member.databricks_uc_impersonation
  ]
}

# ==============================================================================
# DATABRICKS MEDALLION CATALOGS (Resolves output.tf errors)
# ==============================================================================

resource "databricks_catalog" "bronze" {
  provider = databricks.workspace
  name     = "bronze"
  comment  = "Bronze catalog for raw ingested data"
}

resource "databricks_catalog" "silver" {
  provider = databricks.workspace
  name     = "silver"
  comment  = "Silver catalog for cleaned and refined data"
}

resource "databricks_catalog" "gold" {
  provider = databricks.workspace
  name     = "gold"
  comment  = "Gold catalog for aggregated business insights"
}
