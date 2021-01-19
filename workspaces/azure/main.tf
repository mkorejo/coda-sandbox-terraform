#########################
######### Setup #########
#########################

locals {
  location = "Central US"
  prefix   = "mkorejo-sandbox"

  my_ip = "72.204.149.59/32"

  nginx_plus_offer     = "nginx-plus-v1"
  nginx_plus_publisher = "nginxinc"
  nginx_plus_sku       = "nginx-plus-ub1804"
}

provider "azurerm" {
  features {}
}

terraform {
  backend "remote" {
    organization = "muradkorejo"

    workspaces {
      name = "azure"
    }
  }
}

#########################
##### Resource Group ####
#########################

resource "azurerm_resource_group" "main" {
  name     = join("-", [local.prefix, "resources"])
  location = local.location
}

#########################
#### Virtual Network ####
#########################

resource "azurerm_virtual_network" "main" {
  name                = join("-", [local.prefix, "network"])
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = join("-", [local.prefix, "internal"])
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

#########################
#### Security Groups ####
#########################

resource "azurerm_network_security_group" "nginx_plus" {
  name                = join("-", [local.prefix, "nginx-plus"])
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "allow-ssh"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = local.my_ip
    destination_address_prefix = "VirtualNetwork"
  }
}

#########################
#### Storage Account ####
#########################

resource "azurerm_storage_account" "main" {
  name                     = "mkorejo"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

#########################
##### Load Balancer #####
#########################

resource "azurerm_public_ip" "lb" {
  name                = join("-", [local.prefix, "lb-ip"])
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = join("-", [local.prefix, "lb"])
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = join("-", [local.prefix, "lb-frontend-ip-config"])
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb" {
  name                = join("-", [local.prefix, "lb-backend-pool"])
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "lb" {
  name                = join("-", [local.prefix, "lb-probe"])
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.lb.id
  port                = 80
  protocol            = "Http"
  request_path        = "/"
  interval_in_seconds = "60"
}

resource "azurerm_lb_rule" "http" {
  name                           = join("-", [local.prefix, "lb-rule-http"])
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.lb.id
  frontend_ip_configuration_name = join("-", [local.prefix, "lb-frontend-ip-config"])
  frontend_port                  = 80
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb.id
  backend_port                   = 80
  probe_id                       = azurerm_lb_probe.lb.id
  protocol                       = "Tcp"
}

resource "azurerm_lb_rule" "https" {
  name                           = join("-", [local.prefix, "lb-rule-https"])
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.lb.id
  frontend_ip_configuration_name = join("-", [local.prefix, "lb-frontend-ip-config"])
  frontend_port                  = 443
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb.id
  backend_port                   = 443
  probe_id                       = azurerm_lb_probe.lb.id
  protocol                       = "Tcp"
}

#########################
###### NGINX Plus #######
#########################

resource "azurerm_marketplace_agreement" "nginx_plus" {
  offer     = local.nginx_plus_offer
  publisher = local.nginx_plus_publisher
  plan      = local.nginx_plus_sku
}

resource "azurerm_linux_virtual_machine_scale_set" "nginx_plus" {
  name                = join("-", [local.prefix, "nginx-plus"])
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
# admin_username      = "adminuser"
  health_probe_id     = azurerm_lb_probe.lb.id
  instances           = 1
  sku                 = "Standard_D2_v2"
  upgrade_mode        = "Automatic"
  zone_balance        = true
  zones               = [1, 2, 3]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("id_rsa.pub")
  }

  automatic_instance_repair {
    enabled = false
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.main.primary_blob_endpoint
  }

  # Instances can change via autoscaling outside of Terraform, so let's ignore any changes to number of instances.
  lifecycle {
    ignore_changes = [instances]
  }

  network_interface {
    name    = "main"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id

      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb.id]

      public_ip_address {
        name = "default"
      }
    }

    network_security_group_id = azurerm_network_security_group.nginx_plus.id
  }

  plan {
    name      = local.nginx_plus_sku
    product   = local.nginx_plus_offer
    publisher = local.nginx_plus_publisher
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  /*
  source_image_reference {
    offer     = local.nginx_plus_offer
    publisher = local.nginx_plus_publisher
    sku       = local.nginx_plus_sku
    version   = "latest"
  }
  */

  source_image_id = "/subscriptions/576f4161-dac1-49eb-b2ab-d5cc3aaa3036/resourceGroups/mkorejo-vm-images/providers/Microsoft.Compute/galleries/nginx_plus_hunterfan/images/default/versions/0.0.1"

  depends_on = [
    azurerm_lb_backend_address_pool.lb,
    azurerm_lb_probe.lb
  ]
}

resource "azurerm_monitor_autoscale_setting" "nginx_plus" {
  name                = join("-", [local.prefix, "nginx-plus"])
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.nginx_plus.id

  profile {
    name = "AutoScale"

    capacity {
      default = 1
      minimum = 1
      maximum = 2
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.nginx_plus.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.nginx_plus.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}

resource "azurerm_log_analytics_workspace" "nginx_plus" {
  name                = join("-", [local.prefix, "nginx-plus"])
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = 365
}
