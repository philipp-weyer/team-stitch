output "azure_ca_endpoint" {
  value = azurerm_cognitive_account.ca_account.endpoint
}

output "azure_ca_primary_key" {
  value = azurerm_cognitive_account.ca_account.primary_access_key
  sensitive = true
}

output "azure_ca_secondary_key" {
  value = azurerm_cognitive_account.ca_account.secondary_access_key
  sensitive = true
}

output "azure_oai_endpoint" {
  value = azurerm_cognitive_account.oai_account.endpoint
}

output "azure_oai_primary_key" {
  value = azurerm_cognitive_account.oai_account.primary_access_key
  sensitive = true
}

output "azure_oai_secondary_key" {
  value = azurerm_cognitive_account.oai_account.secondary_access_key
  sensitive = true
}

output "key_id" {
  value = aws_iam_access_key.stitch_access_key.id
}

output "secret_key" {
  value = aws_iam_access_key.stitch_access_key.secret
  sensitive = true
}

output "lambda_ip" {
  value = aws_eip.nat_eip.public_ip
}
