output "vcn_id" {
  description = "OCID da VCN criada"
  value       = module.vcn.vcn_id
}

output "subnet_id" {
  description = "OCID da subnet pública"
  value       = oci_core_subnet.public.id
}



# ============================================================
# 🎯 LIVE: Descomentar os outputs conforme criar os recursos
# ============================================================

# # -----------------------------------------------------
# # NETWORKING
# # -----------------------------------------------------
# output "vcn_id_new" {
#   description = "OCID da VCN"
#   value       = oci_core_vcn.main.id
# }

# output "subnet_public_1_id" {
#   description = "OCID da subnet pública 1"
#   value       = oci_core_subnet.public_1.id
# }

# output "subnet_public_2_id" {
#   description = "OCID da subnet pública 2"
#   value       = oci_core_subnet.public_2.id
# }

# output "subnet_private_1_id" {
#   description = "OCID da subnet privada 1"
#   value       = oci_core_subnet.private_1.id
# }

# output "subnet_private_2_id" {
#   description = "OCID da subnet privada 2"
#   value       = oci_core_subnet.private_2.id
# }

# # -----------------------------------------------------
# # OKE - Oracle Kubernetes Engine
# # -----------------------------------------------------
# output "oke_cluster_id" {
#   description = "OCID do cluster OKE"
#   value       = oci_containerengine_cluster.main.id
# }

# output "oke_cluster_endpoint" {
#   description = "Endpoint do cluster OKE"
#   value       = oci_containerengine_cluster.main.endpoints[0].kubernetes
# }

# output "oke_kubeconfig_command" {
#   description = "Comando para obter kubeconfig"
#   value       = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.main.id} --file $HOME/.kube/config --region ${var.region} --token-version 2.0.0"
# }

# # -----------------------------------------------------
# # REDIS
# # -----------------------------------------------------
# output "redis_endpoint" {
#   description = "Endpoint do Redis cluster"
#   value       = oci_redis_redis_cluster.main.primary_endpoint
# }

# output "redis_port" {
#   description = "Porta do Redis"
#   value       = oci_redis_redis_cluster.main.primary_endpoint_port
# }

# # -----------------------------------------------------
# # NOSQL (DynamoDB equivalent)
# # -----------------------------------------------------
# output "nosql_table_id" {
#   description = "OCID da tabela NoSQL"
#   value       = oci_nosql_table.toggle_master_analytics.id
# }

# output "nosql_table_name" {
#   description = "Nome da tabela NoSQL"
#   value       = oci_nosql_table.toggle_master_analytics.name
# }

# # -----------------------------------------------------
# # QUEUE (SQS equivalent)
# # -----------------------------------------------------
# output "queue_id" {
#   description = "OCID da fila principal"
#   value       = oci_queue_queue.main.id
# }

# output "queue_endpoint" {
#   description = "Endpoint da fila"
#   value       = oci_queue_queue.main.messages_endpoint
# }

# output "queue_dlq_id" {
#   description = "OCID da Dead Letter Queue"
#   value       = oci_queue_queue.dlq.id
# }

# # -----------------------------------------------------
# # REGISTRY (ECR equivalent)
# # -----------------------------------------------------
# output "ocir_repositories" {
#   description = "URLs dos repositórios OCIR"
#   value = {
#     api_gateway          = "${var.region}.ocir.io/${data.oci_objectstorage_namespace.ns.namespace}/${oci_artifacts_container_repository.api_gateway.display_name}"
#     user_service         = "${var.region}.ocir.io/${data.oci_objectstorage_namespace.ns.namespace}/${oci_artifacts_container_repository.user_service.display_name}"
#     order_service        = "${var.region}.ocir.io/${data.oci_objectstorage_namespace.ns.namespace}/${oci_artifacts_container_repository.order_service.display_name}"
#     payment_service      = "${var.region}.ocir.io/${data.oci_objectstorage_namespace.ns.namespace}/${oci_artifacts_container_repository.payment_service.display_name}"
#     notification_service = "${var.region}.ocir.io/${data.oci_objectstorage_namespace.ns.namespace}/${oci_artifacts_container_repository.notification_service.display_name}"
#   }
# }

# # -----------------------------------------------------
# # Data Source para namespace do Object Storage
# # -----------------------------------------------------
# data "oci_objectstorage_namespace" "ns" {
#   compartment_id = var.compartment_id
# }
