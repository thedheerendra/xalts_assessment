## Terraform README

## Description

This Terraform script sets up an Azure infrastructure for a virtual machine (VM) along with necessary networking components. It creates the following resources:

*   **Resource Group**: Named "xalta-rg" in the "Central India" region.
*   **Virtual Network**: Named "xalts-vpc" with an address space of 10.0.0.0/16.
*   **Subnet**: Named "xalts-subnet" within the virtual network with the address prefix 10.0.2.0/24.
*   **Public IP Address**: Named "xalts-ip" with dynamic allocation.
*   **Network Interface**: Named "xalts-nic" associated with the subnet and public IP.
*   **Linux Virtual Machine**: Named "xalts-vm" with Ubuntu OS, configured with specified size, username, password, and SSH authentication. It also provisions two files (`health.py` and `dockerfile`) onto the VM and executes commands for Docker setup and application deployment.
*   **Network Security Group (NSG)**: Named "xalts-nsg" with rules allowing SSH (port 22), HTTP (port 80), HTTPS (port 443), and custom port (3000) traffic.
*   **Network Interface Security Group Association**: Associates the NSG with the network interface.

## Prerequisites

Before applying this Terraform script, ensure you have the following:

*   Azure subscription and appropriate permissions.
*   Terraform installed locally.

## Files Description:

1.  `azure.tf`: Contains essential details for Azure provider and connection, such as client ID and client secret.
2.  `terraform.tf`: Terraform script responsible for provisioning the required resources.
3.  `health.py`: Source code of the application.
4.  `Dockerfile`: Dockerfile for building the Docker image for the `health.py` application.

## Instructions to Run Terraform Script:

1.  **Download:** Download all the files and place them in the same directory.
2.  **Update Credentials:** Open `azure.tf` and update the necessary credentials as per your Azure account. This step ensures Terraform can authenticate and interact with your Azure resources.
3.  **Initialize Terraform:** Run the command `terraform init` in your terminal. This initializes the working directory and prepares Terraform to manage your infrastructure.
4.  **Plan Deployment:** Execute `terraform plan` to see the proposed changes before applying. This step gives you a preview of what Terraform will do without actually making any changes to your infrastructure.
5.  **Apply Changes:** Once you're ready, apply the changes by running `terraform apply`. This command executes the planned changes and provisions the resources specified in your Terraform configuration.

These steps will create a Virtual Machine (VM) in Azure, build a Docker image, and deploy the `health.py` application on the VM.

## After Successfully Completing These Steps:

Upon successful completion, navigate to the Azure portal to retrieve the public IP address of the VM. Then, access the health endpoint of the application by pasting the following URL in your browser: `https://VirtualMachinePublicIP:3000/health`.
