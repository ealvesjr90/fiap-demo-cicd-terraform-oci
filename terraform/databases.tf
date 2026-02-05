# ============================================================
# DATABASES - PostgreSQL (Autonomous Database)
# ============================================================
# Equivalente AWS: RDS PostgreSQL (3 instâncias)
#
# 🎯 LIVE: Descomentar este arquivo para criar os bancos de dados
#
# OCI oferece duas opções:
# 1. Autonomous Database (serverless, mais simples) ← RECOMENDADO
# 2. DB System (VM dedicada, mais controle)
# ============================================================

# # -----------------------------------------------------
# # PostgreSQL Database 1 - Aplicação Principal
# # -----------------------------------------------------
# resource "oci_database_autonomous_database" "postgres_1" {
#   compartment_id           = var.compartment_id
#   db_name                  = "${replace(var.project_name, "-", "")}db1"
#   display_name             = "${var.project_name}-postgres-1"
#   db_workload              = "OLTP"
#   is_free_tier             = var.db_is_free_tier
#   cpu_core_count           = var.db_cpu_core_count
#   data_storage_size_in_tbs = var.db_storage_size_tb
#   admin_password           = var.db_admin_password
#
#   # Rede
#   subnet_id                    = oci_core_subnet.private_1.id
#   nsg_ids                      = []
#   is_mtls_connection_required  = false
#
#   # Backup
#   is_auto_scaling_enabled             = true
#   is_auto_scaling_for_storage_enabled = true
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Database"    = "postgres-1"
#   }
# }

# # -----------------------------------------------------
# # PostgreSQL Database 2 - Serviço Secundário
# # -----------------------------------------------------
# resource "oci_database_autonomous_database" "postgres_2" {
#   compartment_id           = var.compartment_id
#   db_name                  = "${replace(var.project_name, "-", "")}db2"
#   display_name             = "${var.project_name}-postgres-2"
#   db_workload              = "OLTP"
#   is_free_tier             = var.db_is_free_tier
#   cpu_core_count           = var.db_cpu_core_count
#   data_storage_size_in_tbs = var.db_storage_size_tb
#   admin_password           = var.db_admin_password
#
#   subnet_id                   = oci_core_subnet.private_1.id
#   is_mtls_connection_required = false
#
#   is_auto_scaling_enabled             = true
#   is_auto_scaling_for_storage_enabled = true
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Database"    = "postgres-2"
#   }
# }

# # -----------------------------------------------------
# # PostgreSQL Database 3 - Analytics/Reporting
# # -----------------------------------------------------
# resource "oci_database_autonomous_database" "postgres_3" {
#   compartment_id           = var.compartment_id
#   db_name                  = "${replace(var.project_name, "-", "")}db3"
#   display_name             = "${var.project_name}-postgres-3"
#   db_workload              = "OLTP"
#   is_free_tier             = var.db_is_free_tier
#   cpu_core_count           = var.db_cpu_core_count
#   data_storage_size_in_tbs = var.db_storage_size_tb
#   admin_password           = var.db_admin_password
#
#   subnet_id                   = oci_core_subnet.private_2.id
#   is_mtls_connection_required = false
#
#   is_auto_scaling_enabled             = true
#   is_auto_scaling_for_storage_enabled = true
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Database"    = "postgres-3"
#   }
# }
