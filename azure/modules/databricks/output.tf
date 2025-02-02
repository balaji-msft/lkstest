output "catalog_name" {
  value = databricks_catalog.lakefusion_catalog.name
}

output "databricks_schema_names" {
  value = [for s in databricks_schema.lakefusion_schemas : s.name]
}

output "metadata_volume_name" {
  value = databricks_volume.metadata_volume.name
}