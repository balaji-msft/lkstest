terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.62.1"
    }
  }
}

resource "databricks_catalog" "lakefusion_catalog" {
  name         = "lakefusion_ai_${var.workspace_id}"
  comment      = "Catalog for Lakefusion AI workspace ${var.workspace_id}"
  storage_root = var.storage_root_path
  force_destroy = true
}

resource "databricks_schema" "lakefusion_schemas" {
  for_each = var.schemas

  catalog_name = databricks_catalog.lakefusion_catalog.name
  name         = each.key
  comment      = each.value
}

resource "databricks_volume" "metadata_volume" {
  name         = "metadata_files"
  catalog_name = databricks_catalog.lakefusion_catalog.name
  schema_name  = "metadata"
  volume_type  = "MANAGED"
  comment      = "Volume for storing metadata files in Lakefusion AI"
}
