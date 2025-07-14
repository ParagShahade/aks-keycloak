# backend.tf - Configures remote backend for Terraform state in Azure Storage

terraform {
  backend "azurerm" {
    resource_group_name  = "my-tf-rg"
    storage_account_name = "mytfstateacct"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}