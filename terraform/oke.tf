# ============================================================
# OKE - Oracle Kubernetes Engine
# ============================================================
# Equivalente AWS: EKS (Elastic Kubernetes Service)
#
# 🎯 LIVE: Descomentar este arquivo para criar o cluster Kubernetes
#
# Versões suportadas (2025): v1.32.1, v1.33.1, v1.34.1 (preview)
# Docs: https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengaboutk8sversions.htm
# ============================================================

# # -----------------------------------------------------
# # OKE Cluster
# # -----------------------------------------------------
# resource "oci_containerengine_cluster" "main" {
#   compartment_id     = var.compartment_id
#   kubernetes_version = var.oke_kubernetes_version
#   name               = "${var.project_name}-oke"
#   vcn_id             = oci_core_vcn.main.id
#
#   endpoint_config {
#     is_public_ip_enabled = true
#     subnet_id            = oci_core_subnet.public_1.id
#   }
#
#   options {
#     service_lb_subnet_ids = [
#       oci_core_subnet.public_1.id,
#       oci_core_subnet.public_2.id
#     ]
#
#     add_ons {
#       is_kubernetes_dashboard_enabled = false
#       is_tiller_enabled               = false
#     }
#
#     kubernetes_network_config {
#       pods_cidr     = var.oke_pods_cidr
#       services_cidr = var.oke_services_cidr
#     }
#   }
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "ManagedBy"   = "Terraform"
#   }
# }

# # -----------------------------------------------------
# # OKE Node Pool - Workers
# # -----------------------------------------------------
# resource "oci_containerengine_node_pool" "main" {
#   cluster_id         = oci_containerengine_cluster.main.id
#   compartment_id     = var.compartment_id
#   kubernetes_version = var.oke_kubernetes_version
#   name               = "${var.project_name}-nodepool"
#
#   node_shape = var.oke_node_shape
#
#   node_shape_config {
#     memory_in_gbs = var.oke_node_memory_gb
#     ocpus         = var.oke_node_ocpus
#   }
#
#   node_config_details {
#     size = var.oke_node_count
#
#     placement_configs {
#       availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
#       subnet_id           = oci_core_subnet.private_1.id
#     }
#
#     placement_configs {
#       availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
#       subnet_id           = oci_core_subnet.private_2.id
#     }
#
#     freeform_tags = {
#       "Environment" = var.environment
#       "Project"     = var.project_name
#     }
#   }
#
#   node_source_details {
#     source_type = "IMAGE"
#     image_id    = var.oke_node_image_id
#   }
#
#   initial_node_labels {
#     key   = "environment"
#     value = var.environment
#   }
#
#   ssh_public_key = var.ssh_public_key
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#   }
# }

# # -----------------------------------------------------
# # Data Source - OKE Node Pool Images
# # -----------------------------------------------------
# data "oci_containerengine_node_pool_option" "main" {
#   node_pool_option_id = "all"
#   compartment_id      = var.compartment_id
# }
