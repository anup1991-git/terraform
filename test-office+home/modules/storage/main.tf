resource "azurerm_resource_group" "arm-rg" {
    name = var.resource_group_name
    location = var.location
} 

resource "azurerm_storage_account" "arm-sg" {
    name = var.storage_account_name
    location = azurerm_resource_group.arm-rg.location
    resource_group_name = azurerm_resource_group.arm-rg.name
    account_tier = "Standard"
    account_replication_type = "LRS"
}