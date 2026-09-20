data "azurerm_container_registry" "acr" {
  name                = "novacartecommapp"
  resource_group_name = "RG-RET-01"

}