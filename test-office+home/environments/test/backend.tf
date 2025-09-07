terraform {
  backend "azurerm" {
    resource_group_name = "anupcore-rg"
    storage_account_name = "tfstoreanup"
    container_name = "test"
    key = "terraform.tfstate"
  }
}
