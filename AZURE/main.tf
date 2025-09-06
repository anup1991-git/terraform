provider "azurerm" {
  features {}
  subscription_id = "34dd877d-99e6-4f99-9a4a-b33f0fdb5b6b"
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-app-architecture"
  location = "South India"
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name = "vnet-main"
  address_space = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
}

# Frontend Subnet
resource "azurerm_subnet" "frontend" {
  name = "subnet-frontend"
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = ["10.0.1.0/24"]
  resource_group_name = azurerm_resource_group.main.name
}

# Backend Subnet
resource "azurerm_subnet" "backend" {
  name = "subnet-backend"
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = ["10.0.2.0/24"]
  resource_group_name = azurerm_resource_group.main.name
}

# DB Subnet
resource "azurerm_subnet" "dbsubnet" {
  name = "subnet-db"
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = ["10.0.3.0/24"]
  resource_group_name = azurerm_resource_group.main.name
}

# NSGs
resource "azurerm_network_security_group" "frontend" {
  name = "nsg_frontend"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_security_group" "backend" {
  name = "nsg_backend"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location  
}

resource "azurerm_network_security_group" "db" {
  name = "nsg_db"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location  
}

# NSG Associations
resource "azurerm_subnet_network_security_group_association" "frontend" {
  network_security_group_id = azurerm_network_security_group.frontend.id
  subnet_id = azurerm_subnet.frontend.id
}

resource "azurerm_subnet_network_security_group_association" "backend" {
  network_security_group_id = azurerm_network_security_group.backend.id
  subnet_id = azurerm_subnet.backend.id
}

resource "azurerm_subnet_network_security_group_association" "db" {
  network_security_group_id = azurerm_network_security_group.db.id
  subnet_id = azurerm_subnet.dbsubnet.id
}

#public_ip
resource "azurerm_public_ip" "pip" {
  name = "pip"
  allocation_method = "Static"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  sku = "Standard"
}

#NAT Gateway
resource "azurerm_nat_gateway" "nat" {
  name = "nat-gateway-main"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  sku_name = "Standard"
  
}

#NAT & public IP Association
resource "azurerm_nat_gateway_public_ip_association" "pipassoc" {
  public_ip_address_id = azurerm_public_ip.pip.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

#NAT and subnet association
resource "azurerm_subnet_nat_gateway_association" "backend" {
  subnet_id = azurerm_subnet.backend.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "db" {
  subnet_id = azurerm_subnet.dbsubnet.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-backend-cluster"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-app"

  default_node_pool {
    name                = "systemnp"
    node_count          = 2
    vm_size             = "Standard_B2s"
    vnet_subnet_id      = azurerm_subnet.backend.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
    network_policy     = "azure"
    service_cidr       = "172.16.0.0/16"
    dns_service_ip     = "172.16.0.10"
  }

  role_based_access_control_enabled = false

  tags = {
    environment = "dev"
  }
}