
output "acr_login_server" {
  value = data.azurerm_container_registry.acr.login_server
}


output "acr_id" {
  value = data.azurerm_container_registry.acr.id
}


output "acr_admin_username" {
  value     = data.azurerm_container_registry.acr.admin_username
  sensitive = true
}