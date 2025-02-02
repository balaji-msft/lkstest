resource "azurerm_mysql_flexible_server" "mysql" {
  name                = "mysql-lakefusion-${var.workspace_id}"
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login    = var.admin_login
  administrator_password = var.admin_password

  backup_retention_days = 7
  sku_name              = "GP_Standard_D2ds_v4"

  lifecycle {
    ignore_changes = [zone]
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_mysql_flexible_database" "mysql" {
  name                = "lakefusion_transactional_db"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  collation           = "utf8mb4_general_ci"
  charset             = "utf8mb4"
}
