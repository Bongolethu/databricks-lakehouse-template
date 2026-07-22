# provider.tf
# ... (terraform block remains the same)

provider "databricks" {
  alias         = "accounts"
  host          = "https://accounts.gcp.databricks.com"
  account_id    = var.databricks_account_id
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
  # ADD THIS LINE:
  username      = "github-deployer@bongo-143414.iam.gserviceaccount.com"
}
