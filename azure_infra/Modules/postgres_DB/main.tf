resource "azurerm_postgresql_flexible_server" "psql_db_server" {
  name                = var.server_name
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  version    = var.postgres_version
  sku_name   = var.sku_name
  storage_mb = var.storage_mb

  public_network_access_enabled = true

  
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id

  charset   = "UTF8"
  collation = "en_US.utf8"
}