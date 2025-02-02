resource "azurerm_resource_group" "main" {
  name     = "test-lakefusion-${var.workspace_id}"
  location = var.location
}
