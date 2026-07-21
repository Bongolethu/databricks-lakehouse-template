variable "prefix" {
  type        = string
  description = "Prefix for resources"
  default     = "bongo"
}

variable "gcp_region" {
  type        = string
  description = "GCP Region"
  default     = "us-central1"
}