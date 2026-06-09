provider "azurerm" {
  features {}
}

# Define the Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  location            = "East US"
  resource_group_name = "example-resources"
  address_space       = ["10.0.0.0/16"]
}

# Define the Subnet
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = "example-resources"
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefix       = "10.0.1.0/24"
}

# Define the Security Group
resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = "East US"
  resource_group_name = "example-resources"

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate Security Group with Subnet
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# Define the Virtual Machine
resource "azurerm_linux_virtual_machine" "example" {
  name                  = "example-vm"
  location              = "East US"
  resource_group_name   = "example-resources"
  size                  = "Standard_B1s"
  admin_username        = "exampleadmin"
  network_interface_ids = [azurerm_network_interface.example.id]
  admin_ssh_key {
    username   = "exampleadmin"
    public_key = "ssh-rsa AAAAB3NzaC1yc2..."
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

# Define the Network Interface
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = "East US"
  resource_group_name = "example-resources"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}