resource "azurerm_private_dns_zone" "private_dns" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "DNS_LINK" {
  name                  = var.link_name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name

  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false
}