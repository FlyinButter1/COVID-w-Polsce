terraform {
  required_providers {
    azurerm = {
      version = ">= 2.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "6a3ff50d-28b3-4b7d-8e88-2b2943103a02"
}


resource "azurerm_resource_group" "rg" {
  name     = "terraform-rg"
  location = "West Europe"
}

#---------------------------------------------------
# storage insance 
# --------------------------------------------------
resource "azurerm_storage_account" "storage" {
  name                     = "covidwpolsce"
  account_tier             = "Standard"
  account_kind             = "BlobStorage"
  account_replication_type = "LRS"
  access_tier              = "Hot"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
}

output "storage_account_primary_connection_string" {
  value = azurerm_storage_account.storage.primary_connection_string
  sensitive = true
}

resource "azurerm_storage_container" "example" {
  name                  = "test-container"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}


# --------------------------------------------------
# container group
# --------------------------------------------------

resource "azurerm_container_group" "covid-w-polsce" {
  name                = "covid-w-polsce"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  os_type             = "Linux"

  container {


    name   = "covid-w-polsce-backend"
    image  = "ghcr.io/flyinbutter1/covid-w-polsce-backend:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8000
      protocol = "TCP"
      
    }
    environment_variables = {
      "AZURE_STORAGE_CONNECTION_STRING" = azurerm_storage_account.storage.primary_connection_string
      STORAGE_CONTAINER= var.STORAGE_CONTAINER

    }
  }

      container {


    name   = "covid-w-polsce-frontend"
    image  = "ghcr.io/flyinbutter1/covid-w-polsce-frontend:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8501
      protocol = "TCP"
      
    }
    environment_variables = {
      BACKEND_URL= var.BACKEND_URL

    }

  }
}



