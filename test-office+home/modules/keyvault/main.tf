resource "azurerm_key_vault" "arkv" {
  name = var.key_vault_name
  sku_name = "standard"
  tenant_id = var.tenant_id
  resource_group_name = var.resource_group_name
  location = var.location
  enabled_for_disk_encryption = true
  purge_protection_enabled = true
  soft_delete_retention_days = 7
  enable_rbac_authorization = true
}
