provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

variable "subscription_id" {
  description = "value of the Azure subscription ID"
  type        = string
  default     = "26f614c0-22f5-442c-b51d-8352ce46e0e7"
}

variable "resource_group_name" {
  description = "Azure resource group"
  type        = string
  default     = "rg-24-04-on-bieber-marcus"
}

variable "location" {
  default = "westeurope"
}

variable "jenkins_instance_count" {
  default = 2
}

variable "web_instance_count" {
  default = 2
}

variable "home_path" {
  description = "path-to-home-dynamic"
  type        = string
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${var.home_path}/.ssh/ansible-key-azure.pem"
  file_permission = "0600"
}

/*
resource "azurerm_resource_group" "main" {
  name     = "kaiwa-project"
  location = var.location
}
*/

resource "azurerm_virtual_network" "main" {
  name                = "main-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  # resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                = "main-subnet"
  resource_group_name = var.resource_group_name
  # resource_group_name = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "jenkins_sg" {
  name                = "jenkins-sg"
  location            = var.location
  resource_group_name = var.resource_group_name
  # resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Jenkins"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "node_exporter"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9100"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "web_sg" {
  name                = "web-sg"
  location            = var.location
  resource_group_name = var.resource_group_name
  # resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "prometheus"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "node_exporter"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9100"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "prom-client"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3001"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "public_ip" {
  count               = var.jenkins_instance_count + var.web_instance_count
  name                = "public-ip-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  # resource_group_name = azurerm_resource_group.main.name
  allocation_method = "Static"
}

resource "azurerm_network_interface" "nic" {
  count               = var.jenkins_instance_count + var.web_instance_count
  name                = "nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  # resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "jenkins_nic_sg_assoc" {
  count                    = var.jenkins_instance_count
  network_interface_id     = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.jenkins_sg.id
}

resource "azurerm_network_interface_security_group_association" "web_nic_sg_assoc" {
  count                    = var.web_instance_count
  network_interface_id     = azurerm_network_interface.nic[count.index + var.jenkins_instance_count].id
  network_security_group_id = azurerm_network_security_group.web_sg.id
}

resource "azurerm_linux_virtual_machine" "jenkins" {
  count               = var.jenkins_instance_count
  name                = "jenkins-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  # resource_group_name = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  size                  = "Standard_B1s"

  admin_username                  = "ubuntu"
  disable_password_authentication = true


  admin_ssh_key {
    username   = "ubuntu"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "jenkins-os-disk-${count.index}"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy" # Ubuntu 22.04 LTS
    sku       = "22_04-lts"                    # Standard-Gen1
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "web" {
  count               = var.web_instance_count
  name                = "web-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  # resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.nic[count.index + var.jenkins_instance_count].id]
  size                  = "Standard_B1s"

  admin_username                  = "ubuntu"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "ubuntu"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "web-os-disk-${count.index}"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy" # Ubuntu 22.04 LTS
    sku       = "22_04-lts"                    # Standard-Gen1
    version   = "latest"
  }

}
