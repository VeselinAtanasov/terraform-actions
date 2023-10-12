variable "resource_group_name" {
  type        = string
  description = "Resounce group name in Azure"
}

variable "resource_group_location" {
  type        = string
  description = "Resounce group location Azure"
}

variable "app_service_plan_name" {
  type        = string
  description = "Application service plan in Azure"
}

variable "app_service_name" {
  type        = string
  description = "Application service in Azure"
}

variable "sql_server_name" {
  type        = string
  description = "MSSQL server name in Azure"
}

variable "sql_database_name" {
  type        = string
  description = "MSSQL database name in Azure"
}

variable "sql_admin_login" {
  type        = string
  description = "MSSQL user admin in Azure"
}

variable "sql_admin_password" {
  type        = string
  description = "MSSQL user password in Azure"
}

variable "firewall_rule_name" {
  type        = string
  description = "Firewall rule name in Azure"
}

variable "repo_url" {
  type        = string
  description = "Gehub repo url"
}

