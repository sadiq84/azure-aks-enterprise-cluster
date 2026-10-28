<div align="center">

# ☸️ Enterprise Azure Kubernetes Service (AKS) Architecture
### Zero-Trust Hardened Kubernetes Platform with Azure CNI Overlay & Workload Identity

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.28.5-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Azure CNI Overlay](https://img.shields.io/badge/Networking-Azure_CNI_Overlay-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)
[![Workload Identity](https://img.shields.io/badge/Security-Azure_AD_Workload_Identity-10B981?style=for-the-badge&logo=shield&logoColor=white)](#)
[![Key Vault CSI](https://img.shields.io/badge/Secrets-Key_Vault_CSI_Driver-F59E0B?style=for-the-badge&logo=azurekeyvault&logoColor=white)](#)
[![Architect](https://img.shields.io/badge/Author-Mohammad_Sadique_Qutub-06B6D4?style=for-the-badge)](#)

```
  ========================================================================================
  [ ZERO-TRUST AKS REFERENCE ARCHITECTURE ]
  * Private Cluster Endpoint & Azure Active Directory RBAC Federation
  * Azure CNI Overlay (IP Exhaustion Mitigation) + Azure Network Policies
  * Dedicated System Node Pool (Tainted) & Autoscaling Workload Node Pools
  * Workload Identity & Azure Key Vault Secrets Store CSI Driver with Auto-Rotation
  ========================================================================================
```

</div>

---

## 📌 Architecture Highlights

1. **Network Architecture (Azure CNI Overlay)**:
   - Solves VNet IP exhaustion by giving pods internal CIDRs (192.168.100.0/24) independent of the host VNet.
   - Host worker nodes occupy VNet subnets (10.200.4.0/22), supporting up to 250 pods per node.
2. **Identity & Access Management (Workload Identity)**:
   - Eliminates static Kubernetes secrets or service account keys.
   - Kubernetes Service Accounts federate directly with Microsoft Entra ID (Azure AD) via OpenID Connect (OIDC).
3. **Secrets Management (Key Vault CSI Driver)**:
   - Secrets mounted as in-memory volumes via SecretProviderClass with automated 2-minute rotation.
4. **Node Pool Separation & Taints**:
   - `systempool`: Tainted with `CriticalAddonsOnly=true:NoSchedule` ensuring user workloads never starve CoreDNS, Metrics Server, or Ingress.
   - `userpool01`: Ephemeral OS disks, autoscaling from 3 to 10 nodes based on P95 compute utilization.

---

## 🏗️ Visual Cluster Topology

```
       [ Microsoft Entra ID (Azure AD) ] <--- OIDC Federation ---> [ Pod ServiceAccount ]
                                                                        |
                                                                        v
+--------------------------------- Azure Private VNet ------------------+---------+
|                                                                                 |
|  +--------------------+       +-----------------------------------------------+  |
|  | AKS Control Plane  | <---> | Worker Node Pool (10.200.4.0/22)              |  |
|  | (Private API)      |       |                                               |  |
|  +--------------------+       |  +-------------------+  +-------------------+ |  |
|                               |  | System Node Pool  |  | User Node Pool    | |  |
|                               |  | (CoreDNS, Calico) |  | (Autoscale 3-10)  | |  |
|                               |  +-------------------+  +-------------------+ |  |
|                               +-----------------------------------------------+  |
+---------------------------------------------------------------------------------+
```

---

## 🚀 Deployment Instructions

```bash
# 1. Initialize Terraform
terraform init

# 2. Plan Infrastructure
terraform plan -var-file="terraform.tfvars.example" -out=tfplan

# 3. Apply Production Cluster
terraform apply tfplan

# 4. Connect to Cluster (Private Endpoint via Bastion/VPN)
az aks get-credentials --resource-group rg-aks-enterprise-prod --name aks-core-enterprise-prod

# 5. Apply Zero-Trust Network Policies & Key Vault CSI
kubectl apply -f k8s-manifests/network-policy-zero-trust.yaml
kubectl apply -f k8s-manifests/secret-provider-class.yaml
kubectl apply -f k8s-manifests/nginx-ingress-tls.yaml
```

---

## 👨‍💻 Author & Maintainer
**Mohammad Sadique Qutub**  
*Senior DevSecOps & Cloud Solutions Architect*  
GitHub: [@sadiq84](https://github.com/sadiq84) • Email: [mohd.sadiq84@gmail.com](mailto:mohd.sadiq84@gmail.com)