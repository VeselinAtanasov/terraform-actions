# Define which provider you are going to use - in this case only azurerm
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.75.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "StorageRG"
    storage_account_name = "taskboardvesko"
    container_name       = "taskboardcontainer"
    key                  = "terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider = mandatory to work
provider "azurerm" {
  features {}
}

# Generate Random Integer
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}${random_integer.ri.result}"
  location = var.resource_group_location
}

# create app service plan for Linux App - shows which kind of machine we are going to use for the app
resource "azurerm_service_plan" "aps" {
  name                = "${var.app_service_plan_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

# crate Myssql Server resource
resource "azurerm_mssql_server" "myssql" {
  name                         = "${var.sql_server_name}-${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login    # "412m1n1fgr324dr"
  administrator_login_password = var.sql_admin_password # "41-323m4y-53ht37-p077w0rd"
}

# create myssql datbase conencted to this myssql server
resource "azurerm_mssql_database" "taskdb" {
  name           = "${var.sql_database_name}-${random_integer.ri.result}"
  server_id      = azurerm_mssql_server.myssql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = "S0"
  zone_redundant = false
}

# crate firewall rule for myssql server:
resource "azurerm_mssql_firewall_rule" "firewall" {
  name             = "${var.firewall_rule_name}-${random_integer.ri.result}"
  server_id        = azurerm_mssql_server.myssql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# create provider for the linux_web_app - i.e. a linux machine wiht node installed 
resource "azurerm_linux_web_app" "task" {
  name                = "${var.app_service_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.aps.location
  service_plan_id     = azurerm_service_plan.aps.id

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.myssql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.taskdb.name};User ID=${azurerm_mssql_server.myssql.administrator_login};Password=${azurerm_mssql_server.myssql.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }
}

# point the repo from which the service weill start - use_manual_integration = false, since we are not going to use CI/CD 
resource "azurerm_app_service_source_control" "taskapp" {
  app_id                 = azurerm_linux_web_app.task.id
  repo_url               = var.repo_url
  branch                 = "main"
  use_manual_integration = true
}