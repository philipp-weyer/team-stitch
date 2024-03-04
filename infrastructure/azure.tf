resource "azurerm_resource_group" "stitch_group" {
  name = "${var.azure_base_name}_rg"
  location = var.azure_region
}

resource "azurerm_cognitive_account" "cognitive_account" {
  name = "${var.azure_base_name}_ca"
  location = var.azure_region
  resource_group_name = azurerm_resource_group.stitch_group.name
  kind = "ComputerVision"

  custom_subdomain_name = "${var.azure_base_name}-vision"

  sku_name = "S1"
}
