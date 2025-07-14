# variable.tf - Defines variables for AKS and Azure resources

variable "prefix" {
  description = "A prefix used for all resources in this example"
  default     = "keycloak"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  default     = "West Europe"
}