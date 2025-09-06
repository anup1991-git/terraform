output "user_identity_id" {
  value = azurerm_user_assigned_identity.az_uid.id
}

output "principal_id" {
  value = azurerm_user_assigned_identity.az_uid.principal_id
}