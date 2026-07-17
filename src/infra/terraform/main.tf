# Create the secure cloud container to act as the Root Metastore boundary
resource "azurerm_storage_data_lake_gen2_filesystem" "metastore_container" {
  name               = "unity-catalog-metastore-root"
  storage_account_id = var.storage_account_resource_id
}

# Connect Databricks Storage Credentials directly to an Azure Managed Identity
resource "databricks_storage_credential" "external_storage_credential" {
  name = "lakehouse_execution_credential"
  azure_managed_identity {
    access_connector_id = var.azure_managed_identity_connector_id
  }
  comment = "Managed Identity used by data_developers to access cloud storage containers securely."
}

# Enforce secure External Location boundaries on top of the raw data storage container
resource "databricks_external_location" "bronze_external_location" {
  name            = "bronze_raw_landing"
  url             = "abfss://${azurerm_storage_data_lake_gen2_filesystem.metastore_container.name}@${var.storage_account_name}.dfs.core.windows.net/bronze"
  credential_name = databricks_storage_credential.external_storage_credential.name
  comment         = "Isolates the raw landing point so compute units do not need direct storage key access."
}