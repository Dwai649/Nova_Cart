output "server_id" {
  value = azurerm_postgresql_flexible_server.psql_db_server.id
}

output "server_name" {
  value = azurerm_postgresql_flexible_server.psql_db_server.name
}

output "server_fqdn" {
  value = azurerm_postgresql_flexible_server.psql_db_server.fqdn
}

output "database_name" {
  value = azurerm_postgresql_flexible_server_database.db_name.name
}