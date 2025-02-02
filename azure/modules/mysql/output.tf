output "server_name" {
  value = azurerm_mysql_flexible_server.mysql.name
}

output "database_name" {
  value = azurerm_mysql_flexible_database.mysql.name
}
