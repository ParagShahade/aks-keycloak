# main.tf - Provisions Azure Resource Group and AKS Cluster for Keycloak Demo

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-k8s-resources"
  location = var.location
  # Resource group for all AKS and related resources
}

resource "azurerm_kubernetes_cluster" "example" {
  # Main AKS cluster for running Keycloak, web app, and supporting services
  name                = "${var.prefix}-k8s"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "${var.prefix}-k8s"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "standard_a2_v2" # Small VM for demo; increase for production
  }

  identity {
    type = "SystemAssigned" # Use managed identity for AKS
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].upgrade_settings,
    ]
  }
}
