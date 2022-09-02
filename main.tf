terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

 subscription_id   = "6b508088-f01a-45e9-b6cf-c41f51866546"
client_id          = "f3a9b86f-7741-4535-b33b-b64a54fd66a0"
client_secret      = "frp8Q~vTFBe.dVvQP_RDpZMlnPwQ43Ot5F-3rb-y"
tenant_id          = "e7f9563f-d6ba-4fb3-b2bf-36aacb28907d"
}


# Create a resource group
resource "azurerm_resource_group" "rg1" {
  name     = "rgterraform"
  location = "West Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet1" {
  name                = "vnetterraform1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  address_space       = ["10.0.0.0/16"]
}
# create a subnet within the vnet
resource "azurerm_subnet" "subv1" {
  name                 = "subnetterraform1"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.1.0/24"]

  }


  #VM

  resource "azurerm_network_interface" "tfnic" {
  name                = "terraform-nic"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subv1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm1" {
  name                = "terraformvm1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.tfnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}