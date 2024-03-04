output "azure_endpoint" {
  value = azurerm_cognitive_account.cognitive_account.endpoint
}

output "azure_primary_key" {
  value = azurerm_cognitive_account.cognitive_account.primary_access_key
  sensitive = true
}

output "azure_secondary_key" {
  value = azurerm_cognitive_account.cognitive_account.secondary_access_key
  sensitive = true
}

output "key_id" {
  value = aws_iam_access_key.stitch_access_key.id
}

output "secret_key" {
  value = aws_iam_access_key.stitch_access_key.secret
  sensitive = true
}
