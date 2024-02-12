provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name   = "sa_rg01"
    storage_account_name  = "cts2024devopsvishwa"
    container_name        = "teamcontainer"
    key                   = "vishwa-uat-k8s.tfstate"
  }
}

resource "azurerm_resource_group" "aks" {
  name     = var.k8s_rg
  location = "East US"
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aksSubnet"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = var.subnet_address
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.k8s_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = var.k8s_name
  kubernetes_version  = "1.27.7"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = var.vm_size
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"
  }

  /*service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }*/

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"

    dns_service_ip    = "10.0.1.10"
    service_cidr      = "10.0.1.0/24"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Env = var.tags
  }
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
