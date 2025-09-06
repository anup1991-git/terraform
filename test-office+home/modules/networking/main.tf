resource "azurerm_virtual_network" "avnet" {
    name = var.virtual_network_name
    address_space = [ var.address_space ]
    resource_group_name = var.resource_group_name
    location = var.location
  }

resource "azurerm_subnet" "avsubnet" {
    name = var.subnet_name
    resource_group_name = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.avnet.name
    count = length(var.subnet_name)
    
}