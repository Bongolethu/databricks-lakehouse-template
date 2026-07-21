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
# IAM & IDENTITY (Workspace Cluster Deployer)
# ==============================================================================

# Workspace Cluster Deployer Service Account
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

# ==============================================================================
# WORKLOAD IDENTITY FEDERATION (For GitHub Actions Deployments)
# ==============================================================================

# Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"
