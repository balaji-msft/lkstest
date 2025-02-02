terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.62.1"
    }
  }
}

provider "azurerm" {
  features {}
}



provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

provider "databricks" {
  host  = var.host
  token = var.token
}

module "resource_group" {
  source       = "./modules/resource_group"
  workspace_id = var.workspace_id
  location     = var.location
}

module "aks" {
  source            = "./modules/aks"
  workspace_id      = var.workspace_id
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
}

module "mysql" {
  source              = "./modules/mysql"
  workspace_id        = var.workspace_id
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  admin_login         = var.mysql_admin_login
  admin_password      = var.mysql_admin_password
}

module "databricks" {
  source       = "./modules/databricks"
  workspace_id = var.workspace_id
  storage_root_path = var.storage_root_path
  schemas      = var.schemas
}
