data "azurerm_client_config" "current" {}

module "keyvault" {
  source = "./modules/keyvault"
  location = "East US"
  key_vault_name = "anup-keyvault"
  tenant_id = data.azurerm_client_config.current.tenant_id
  resource_group_name = "anupcore-rg"
}

module "managed_identity" {
  source = "./modules/identity/managed-identity"
  resource_group_name = "anupcore-rg"
  location = "East US"
  uid_name = "anup-uid"
}

resource "azurerm_role_assignment" "self_access" {
  scope                = module.keyvault.key_vault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

module "role_assignment" {  
  source = "./modules/identity/role-assignment"
  scope = module.keyvault.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id = module.managed_identity.principal_id
}

resource "azurerm_key_vault_secret" "secret-test" {
  name = "anup-secret"
  value = var.password
  key_vault_id = module.keyvault.key_vault_id
  depends_on = [module.keyvault]  
}

