resource "azurerm_user_assigned_identity" "az_uid" {
  name = var.uid_name
  resource_group_name = var.resource_group_name
  location = var.location
}