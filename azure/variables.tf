variable "workspace_id" {
  description = "Workspace identifier"
  type        = string
}

variable "location" {
  description = "Location for Azure resources"
  type        = string
}

variable "mysql_admin_login" {
  description = "MySQL administrator login name"
  type        = string
}

variable "mysql_admin_password" {
  description = "MySQL administrator password"
  type        = string
}

variable "host" {
  description = "Databricks workspace host URL"
  type        = string
}

variable "token" {
  description = "Databricks authentication token"
  type        = string
}

variable "storage_root_path" {
  description = "Storage root path for Databricks"
  type        = string
}

variable "schemas" {
  default = {
    embedding = "This is a schema for embeddings."
    llm       = "This is a schema for LLMs."
    gold      = "This is a schema for the gold layer."
    silver    = "This is a schema for the silver layer."
    metadata  = "This is a schema for metadata."
    transactional_db="This is a schema for transactional_db "
  }
}
