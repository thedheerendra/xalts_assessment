resource "azurerm_resource_group" "rg" {
  name     = "xalta-rg"
  location = "Central India"
}

resource "azurerm_virtual_network" "xalts-vpc" {
  name                = "xalts-vpc"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "xalts-subnet" {
  name                 = "xalts-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.xalts-vpc.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "xalts-ip" {
  name                = "xalts-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "xalts-nic" {
  name                = "xalts-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ip"
    subnet_id                     = azurerm_subnet.xalts-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "xalts-vm" {
  name                = "xalts-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2as_v5"
  admin_username      = "adminuser"
  admin_password      = "12345@abcD"
  disable_password_authentication = "false"
  network_interface_ids = [
    azurerm_network_interface.xalts-nic.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  provisioner "file" {
    source      = "./health.py"  # Specify the path to your local file
    destination = "/"  # Specify the destination path on the VM
    connection {
      type        = "ssh"
      user        = "adminuser"  # Replace with the username of your VM
      password    = "12345@abcD"  # Replace with your password
      host        = azurerm_public_ip.xalts-ip.ip_address  # Use the public IP of your VM
    }
  }
  provisioner "file" {
    source      = "./dockerfile"  # Specify the path to your local file
    destination = "/"  # Specify the destination path on the VM
    connection {
      type        = "ssh"
      user        = "adminuser"  # Replace with the username of your VM
      password    = "12345@abcD"  # Replace with your password
      host        = azurerm_public_ip.xalts-ip.ip_address  # Use the public IP of your VM
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io"
      "docker build -t xalt . "
      "docker run -p 3000:3000 xalt"
    ]

    connection {
      type     = "ssh"
      user     = "adminuser"  # Replace with the username of your VM
      password = "1234@abcD"  # Replace with your password
      host     = azurerm_public_ip.xalts-ip.ip_address  # Use the public IP of your VM
    }
  }
}
resource "azurerm_network_security_group" "xalts-nsg" {
  name                = "xalts-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_http"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_https"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_http"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "xalts-nisga" {
  network_interface_id      = azurerm_network_interface.xalts-nic.id
  network_security_group_id = azurerm_network_security_group.xalts-nsg.id
}
