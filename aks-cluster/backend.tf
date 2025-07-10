terraform {
  backend "azurerm" {
    resource_group_name  = "my-tf-rg"
    storage_account_name = "mytfstateacct"
    container_name       = "tfstate"
    key                  = "aks/${terraform.workspace}/terraform.tfstate"
  }
}