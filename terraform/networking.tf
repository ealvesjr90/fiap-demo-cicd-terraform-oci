# ============================================================
# NETWORKING - VCN, Subnets, Gateways, Route Tables
# ============================================================
# Equivalente AWS: VPC, Subnets (Public/Private), IGW, NAT, Route Tables
#
# 🎯 LIVE: Descomentar este arquivo para criar a rede
# ============================================================

# # -----------------------------------------------------
# # VCN (Virtual Cloud Network) - Equivalente a VPC
# # -----------------------------------------------------
# resource "oci_core_vcn" "main" {
#   compartment_id = var.compartment_id
#   display_name   = "${var.project_name}-vcn"
#   cidr_blocks    = [var.vcn_cidr]
#   dns_label      = replace(var.project_name, "-", "")
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "ManagedBy"   = "Terraform"
#   }
# }

# # -----------------------------------------------------
# # Internet Gateway - Acesso público à internet
# # -----------------------------------------------------
# resource "oci_core_internet_gateway" "main" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.main.id
#   display_name   = "${var.project_name}-igw"
#   enabled        = true
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#   }
# }

# # -----------------------------------------------------
# # NAT Gateway - Acesso à internet para subnets privadas
# # -----------------------------------------------------
# resource "oci_core_nat_gateway" "main" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.main.id
#   display_name   = "${var.project_name}-nat"
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#   }
# }

# # -----------------------------------------------------
# # Service Gateway - Acesso aos serviços OCI (Object Storage, etc)
# # -----------------------------------------------------
# data "oci_core_services" "all_services" {
#   filter {
#     name   = "name"
#     values = ["All .* Services In Oracle Services Network"]
#     regex  = true
#   }
# }

# resource "oci_core_service_gateway" "main" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.main.id
#   display_name   = "${var.project_name}-sgw"
#
#   services {
#     service_id = data.oci_core_services.all_services.services[0].id
#   }
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#   }
# }

# # -----------------------------------------------------
# # Route Table - Pública (via Internet Gateway)
# # -----------------------------------------------------
# resource "oci_core_route_table" "public" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.main.id
#   display_name   = "${var.project_name}-rt-public"
#
#   route_rules {
#     destination       = "0.0.0.0/0"
#     destination_type  = "CIDR_BLOCK"
#     network_entity_id = oci_core_internet_gateway.main.id
#   }
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#   }
# }

# # -----------------------------------------------------
# # Route Table - Privada (via NAT Gateway + Service Gateway)
# # -----------------------------------------------------
# resource "oci_core_route_table" "private" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.main.id
#   display_name   = "${var.project_name}-rt-private"
#
#   route_rules {
#     destination       = "0.0.0.0/0"
#     destination_type  = "CIDR_BLOCK"
#     network_entity_id = oci_core_nat_gateway.main.id
#   }
#
#   route_rules {
#     destination       = data.oci_core_services.all_services.services[0].cidr_block
#     destination_type  = "SERVICE_CIDR_BLOCK"
#     network_entity_id = oci_core_service_gateway.main.id
#   }
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#   }
# }

# # -----------------------------------------------------
# # Security List - Pública (SSH, HTTP, HTTPS, NodePort)
# # -----------------------------------------------------
# resource "oci_core_security_list" "public" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.main.id
#   display_name   = "${var.project_name}-sl-public"
#
#   # Egress - Permitir todo tráfego de saída
#   egress_security_rules {
#     destination = "0.0.0.0/0"
#     protocol    = "all"
#   }
#
#   # Ingress - SSH
#   ingress_security_rules {
#     protocol = "6" # TCP
#     source   = "0.0.0.0/0"
#     tcp_options {
#       min = 22
#       max = 22
#     }
#   }
#
#   # Ingress - HTTP
#   ingress_security_rules {
#     protocol = "6"
#     source   = "0.0.0.0/0"
#     tcp_options {
#       min = 80
#       max = 80
#     }
#   }
#
#   # Ingress - HTTPS
#   ingress_security_rules {
#     protocol = "6"
#     source   = "0.0.0.0/0"
#     tcp_options {
#       min = 443
#       max = 443
#     }
#   }
#
#   # Ingress - Kubernetes NodePort range
#   ingress_security_rules {
#     protocol = "6"
#     source   = "0.0.0.0/0"
#     tcp_options {
#       min = 30000
#       max = 32767
#     }
#   }
#
#   # Ingress - ICMP (ping)
#   ingress_security_rules {
#     protocol = "1" # ICMP
#     source   = "0.0.0.0/0"
#   }
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#   }
# }

# # -----------------------------------------------------
# # Security List - Privada (interno VCN + serviços)
# # -----------------------------------------------------
# resource "oci_core_security_list" "private" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.main.id
#   display_name   = "${var.project_name}-sl-private"
#
#   # Egress - Permitir todo tráfego de saída
#   egress_security_rules {
#     destination = "0.0.0.0/0"
#     protocol    = "all"
#   }
#
#   # Ingress - Todo tráfego interno da VCN
#   ingress_security_rules {
#     protocol = "all"
#     source   = var.vcn_cidr
#   }
#
#   # Ingress - Kubernetes API (do OKE control plane)
#   ingress_security_rules {
#     protocol = "6"
#     source   = "0.0.0.0/0"
#     tcp_options {
#       min = 6443
#       max = 6443
#     }
#   }
#
#   # Ingress - Kubelet
#   ingress_security_rules {
#     protocol = "6"
#     source   = var.vcn_cidr
#     tcp_options {
#       min = 10250
#       max = 10250
#     }
#   }
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#   }
# }

# # -----------------------------------------------------
# # Subnet Pública 1 (AD1) - Load Balancers, Bastion
# # -----------------------------------------------------
# resource "oci_core_subnet" "public_1" {
#   compartment_id             = var.compartment_id
#   vcn_id                     = oci_core_vcn.main.id
#   display_name               = "${var.project_name}-subnet-public-1"
#   cidr_block                 = var.subnet_public_1_cidr
#   availability_domain        = data.oci_identity_availability_domains.ads.availability_domains[0].name
#   route_table_id             = oci_core_route_table.public.id
#   security_list_ids          = [oci_core_security_list.public.id]
#   dns_label                  = "public1"
#   prohibit_public_ip_on_vnic = false
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Type"        = "public"
#   }
# }

# # -----------------------------------------------------
# # Subnet Pública 2 (AD2) - Load Balancers (HA)
# # -----------------------------------------------------
# resource "oci_core_subnet" "public_2" {
#   compartment_id             = var.compartment_id
#   vcn_id                     = oci_core_vcn.main.id
#   display_name               = "${var.project_name}-subnet-public-2"
#   cidr_block                 = var.subnet_public_2_cidr
#   availability_domain        = data.oci_identity_availability_domains.ads.availability_domains[1].name
#   route_table_id             = oci_core_route_table.public.id
#   security_list_ids          = [oci_core_security_list.public.id]
#   dns_label                  = "public2"
#   prohibit_public_ip_on_vnic = false
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Type"        = "public"
#   }
# }

# # -----------------------------------------------------
# # Subnet Privada 1 (AD1) - OKE Workers, Databases
# # -----------------------------------------------------
# resource "oci_core_subnet" "private_1" {
#   compartment_id             = var.compartment_id
#   vcn_id                     = oci_core_vcn.main.id
#   display_name               = "${var.project_name}-subnet-private-1"
#   cidr_block                 = var.subnet_private_1_cidr
#   availability_domain        = data.oci_identity_availability_domains.ads.availability_domains[0].name
#   route_table_id             = oci_core_route_table.private.id
#   security_list_ids          = [oci_core_security_list.private.id]
#   dns_label                  = "private1"
#   prohibit_public_ip_on_vnic = true
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Type"        = "private"
#   }
# }

# # -----------------------------------------------------
# # Subnet Privada 2 (AD2) - OKE Workers, Databases (HA)
# # -----------------------------------------------------
# resource "oci_core_subnet" "private_2" {
#   compartment_id             = var.compartment_id
#   vcn_id                     = oci_core_vcn.main.id
#   display_name               = "${var.project_name}-subnet-private-2"
#   cidr_block                 = var.subnet_private_2_cidr
#   availability_domain        = data.oci_identity_availability_domains.ads.availability_domains[1].name
#   route_table_id             = oci_core_route_table.private.id
#   security_list_ids          = [oci_core_security_list.private.id]
#   dns_label                  = "private2"
#   prohibit_public_ip_on_vnic = true
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Type"        = "private"
#   }
# }

# # -----------------------------------------------------
# # Data Source - Availability Domains
# # -----------------------------------------------------
# data "oci_identity_availability_domains" "ads" {
#   compartment_id = var.tenancy_ocid
# }
