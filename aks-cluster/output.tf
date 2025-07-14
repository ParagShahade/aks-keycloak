# output.tf - Outputs important AKS and resource information after deployment

# (Add outputs here as needed, e.g. AKS cluster name, kubeconfig, etc.)

output "id" {
  value = azurerm_kubernetes_cluster.example.id
}
