output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  value = {
    for x, y in azurerm_subnet.subnets :
    x => y.id
  }
}

output "subnet_names" {
  value = keys(azurerm_subnet.subnets)
}

