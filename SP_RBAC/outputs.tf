output "sp_clientid" {
  value = azuread_service_principal.sp_client.id

}

output "sp_pass" {
  value     = azuread_service_principal_password.sp_pass.value
  sensitive = true
}

