terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.97"
    }
  }

  backend "azurerm" {
    resource_group_name  = "s194d00-security-dns"
    storage_account_name = "tfstatek4mb8z"
    container_name       = "tfstate"
    key                  = "security-dns.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# ===========

locals {
  resource_group = "s194d00-security-dns"
  tags = {
    "Product"          = "Protective Monitoring - Splunk SaaS"
    "Environment"      = "Dev"
    "Service Offering" = "Security DNS"
  }

}

resource "azurerm_resource_group" "security_dns_rg" {
  name     = local.resource_group
  location = "West Europe"
  tags     = local.tags
}

resource "azurerm_dns_zone" "security_dns_zone" {
  name                = "security.education.gov.uk"
  resource_group_name = azurerm_resource_group.security_dns_rg.name
  tags                = local.tags
}

resource "random_string" "resource_code_sg" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_storage_account" "dns_tfstate" {
  name                            = "tfstate${random_string.resource_code_sg.result}"
  resource_group_name             = azurerm_resource_group.security_dns_rg.name
  location                        = azurerm_resource_group.security_dns_rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"
  tags                            = local.tags
    #infrastructure_encryption_enabled = true
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.dns_tfstate.name
  container_access_type = "private"
}