# ==========================================
# 1. TERRAFORM PROVIDERS CONFIGURATION
# ==========================================
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.0"
    }
  }
}

# ==========================================
# 2. INPUT VARIABLES
# ==========================================
variable "storage_account_name" {
  type        = string
  description = "The name of the Azure ADLS Gen2 storage account for the Lakehouse."
}

variable "storage_account_resource_id" {
  type        = string
  description = "The resource ID of the storage account for file system mounting."
}

variable "azure_managed_identity_connector_id" {
  type        = string
  description = "The resource ID of the Azure Databricks Access Connector."
}

# ==========================================
# 3. DYNAMIC PERSONA INPUT PARSING
# ==========================================
locals {
  # Dynamically pull persona structures declared at the repository root
  solution_architect  = jsondecode(file("${path.module}/../../.databricks/personas/solution-architect.json"))
  technical_analyst   = jsondecode(file("${path.module}/../../.databricks/personas/technical-analyst.json"))
  business_analyst    = jsondecode(file("${path.module}/../../.databricks/personas/business-analyst.json"))
  data_developer      = jsondecode(file("${path.module}/../../.databricks/personas/data-developer.json"))
}

# ==========================================
# 4. IDENTITY PROVIDER (SCIM ENTITLEMENTS)
# ==========================================
resource "databricks_group" "solution_architects" {
  display_name          = local.solution_architect.persona
  allow_cluster_create  = local.solution_architect.workspace_access.entitlements.workspace-access
  databricks_sql_access = local.solution_architect.workspace_access.entitlements.databricks-sql-access
}

resource "databricks_group" "technical_analysts" {
  display_name          = local.technical_analyst.persona
  databricks_sql_access = local.technical_analyst.workspace_access.entitlements.databricks-sql-access
}

resource "databricks_group" "business_analysts" {
  display_name          = local.business_analyst.persona
  databricks_sql_access = local.business_analyst.workspace_access.entitlements.databricks-sql-access
}

resource "databricks_group" "data_developers" {
  display_name          = local.data_developer.persona
  allow_cluster_create  = local.data_developer.workspace_access.entitlements.workspace-access
  databricks_sql_access = local.data_developer.workspace_access.entitlements.databricks-sql-access
}

# ==========================================
# 5. SECURE STORAGE & UNITY CATALOG MOUNTING
# ==========================================
resource "azurerm_storage_data_lake_gen2_filesystem" "metastore_container" {
  name               = "unity-catalog-metastore-root"
  storage_account_id = var.storage_account_resource_id
}

resource "databricks_storage_credential" "external_storage_credential" {
  name = "lakehouse_execution_credential"
  azure_managed_identity {
    access_connector_id = var.azure_managed_identity_connector_id
  }
  comment = "Managed identity wrapper leveraged by the DLT execution cluster engines."
  depends_on = [azurerm_storage_data_lake_gen2_filesystem.metastore_container]
}

resource "databricks_external_location" "bronze_external_location" {
  name            = "bronze_raw_landing"
  url             = "abfss://${azurerm_storage_data_lake_gen2_filesystem.metastore_container.name}@${var.storage_account_name}.dfs.core.windows.net/bronze"
  credential_name = databricks_storage_credential.external_storage_credential.name
  comment         = "Isolates the raw landing entry zone boundary."
}

# ==========================================
# 6. ENCRYPTED VAULT SECRETS BACKING
# ==========================================
resource "databricks_secret_scope" "ai_credentials" {
  name                     = "ai_credentials"
  initial_manage_principal = "users"
}

# Grant Data Developers read access to authorization variables for testing purposes
resource "databricks_secret_acl" "dev_secret_access" {
  principal  = databricks_group.data_developers.display_name
  scope      = databricks_secret_scope.ai_credentials.name
  permission = "READ"
}

# ==========================================
# 7. OUTPUT CONFIGURATIONS
# ==========================================
output "storage_credential_name" {
  value = databricks_storage_credential.external_storage_credential.name
}

output "bronze_path" {
  value = databricks_external_location.bronze_external_location.url
}