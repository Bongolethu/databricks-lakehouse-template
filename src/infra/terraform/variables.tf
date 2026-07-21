# variables.tf

variable "gcp_project_id" {
  type        = string
  description = "The GCP Project ID where resources will be created"
}

variable "databricks_host" {
  type        = string
  description = "The Databricks workspace URL (e.g., https://<instance-id>.cloud.databricks.com)"
}

variable "prefix" {
  type        = string
  description = "Prefix applied to created resources"
  default     = "bongo"
}

variable "gcp_region" {
  type        = string
  description = "The GCP region for storage buckets and compute resources"
  default     = "us-central1"
}