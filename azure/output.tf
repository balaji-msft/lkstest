output "resource_group_name" {
  value = module.resource_group.name
}

output "aks_cluster_name" {
  value = module.aks.name
}

output "mysql_flexible_server_name" {
  value = module.mysql.server_name
}

output "mysql_database_name" {
  value = module.mysql.database_name
}

output "databricks_catalog_name" {
  value = module.databricks.catalog_name
}
