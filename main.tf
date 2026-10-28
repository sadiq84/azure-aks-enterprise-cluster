resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Tier        = "ContainerPlatform"
    Architect   = "Mohammad Sadique Qutub"
  }
}

# 1. Dedicated Virtual Network & Subnet for AKS
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.cluster_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "snet-aks-nodes"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.aks_subnet_prefix
}

# 2. Centralized Log Analytics Workspace for Container Insights
resource "azurerm_log_analytics_workspace" "laws" {
  name                = "laws-${var.cluster_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

# 3. User-Assigned Managed Identity for AKS Control Plane
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "id-${var.cluster_name}-controlplane"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Network Contributor Role on Subnet for AKS Identity
resource "azurerm_role_assignment" "aks_subnet_network_contributor" {
  scope                = azurerm_subnet.aks_subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# 4. Production-Grade Enterprise AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.cluster_name}-dns"
  kubernetes_version  = var.kubernetes_version

  # Zero-Trust Security Features
  private_cluster_enabled = true
  oidc_issuer_enabled     = true
  workload_identity_enabled = true
  local_account_disabled  = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  # System Node Pool (Tainted for Core Addons Only)
  default_node_pool {
    name                = "systempool"
    node_count          = var.system_node_count
    vm_size             = "Standard_D2s_v5"
    vnet_subnet_id      = azurerm_subnet.aks_subnet.id
    os_disk_size_gb     = 64
    os_disk_type        = "Managed"
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = false

    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
    }

    only_critical_addons_enabled = true
  }

  # Azure CNI Overlay with Azure Network Policies
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"
    dns_service_ip      = "192.168.100.10"
    service_cidr        = "192.168.100.0/24"
    load_balancer_sku   = "standard"
  }

  # Entra ID (Azure AD) RBAC Integration
  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
  }

  # Key Vault Secrets Store CSI Driver
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # Monitoring & Container Insights
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.laws.id
  }

  # Microsoft Defender for Containers
  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.laws.id
  }

  depends_on = [azurerm_role_assignment.aks_subnet_network_contributor]
}

# 5. User Workload Node Pool (Autoscaling)
resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                  = "userpool01"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.user_node_vm_size
  vnet_subnet_id        = azurerm_subnet.aks_subnet.id
  enable_auto_scaling   = true
  min_count             = var.user_node_min_count
  max_count             = var.user_node_max_count
  os_disk_size_gb       = 128
  os_disk_type          = "Ephemeral"
  mode                  = "User"

  node_labels = {
    "nodepool-type" = "workload"
    "workload"      = "enterprise-apps"
  }

  upgrade_settings {
    max_surge = "33%"
  }
}
