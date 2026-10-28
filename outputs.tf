output "aks_cluster_id" {
  description = "Resource ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_cluster_name" {
  description = "Name of the provisioned AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL for Azure AD Workload Identity federation."
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

output "key_vault_secrets_provider_client_id" {
  description = "The Client ID of the Managed Identity used by the Key Vault CSI Driver."
  value       = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].client_id
}

output "log_analytics_workspace_id" {
  description = "The Resource ID of the Container Insights Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.laws.id
}
