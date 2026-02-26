data "oci_containerengine_node_pool_options" "oke_options" {
  compartment_id = var.compartment_id
}



# ============================================================
# DATA SOURCE - Availability Domains
# ============================================================
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# ============================================================
# VCN
# ============================================================
module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.6.0"

  compartment_id = var.compartment_id
  region         = var.region

  vcn_name      = "${var.project_name}-vcn"
  vcn_dns_label = replace("${var.project_name}vcn", "-", "")
  vcn_cidrs     = [var.vcn_cidr]

  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true
}

# ============================================================
# SUBNETS
# ============================================================

# Subnet pública (LoadBalancer / API Endpoint)
resource "oci_core_subnet" "public" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = var.subnet_cidr
  display_name   = "${var.project_name}-public-subnet"
  dns_label      = "public"
  route_table_id = module.vcn.ig_route_id

  prohibit_public_ip_on_vnic = false
}

# Subnet privada - Workers OKE
resource "oci_core_subnet" "private_workers" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = var.oke_subnet_workers_cidr
  display_name   = "${var.project_name}-workers-subnet"
  dns_label      = "workers"
  route_table_id = module.vcn.nat_route_id

  prohibit_public_ip_on_vnic = true
}

# Subnet privada - Databases
resource "oci_core_subnet" "private_db" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = var.oke_subnet_db_cidr
  display_name   = "${var.project_name}-db-subnet"
  dns_label      = "db"
  route_table_id = module.vcn.nat_route_id

  prohibit_public_ip_on_vnic = true
}

# ============================================================
# SECURITY LIST
# ============================================================
resource "oci_core_default_security_list" "default" {
  manage_default_resource_id = module.vcn.vcn_all_attributes.default_security_list_id

  display_name = "${var.project_name}-default-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  dynamic "ingress_security_rules" {
    for_each = var.ingress_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0"
      tcp_options {
        min = ingress_security_rules.value
        max = ingress_security_rules.value
      }
    }
  }
}

# ============================================================
# OKE - Oracle Kubernetes Engine
# ============================================================

resource "oci_containerengine_cluster" "oke" {
  compartment_id     = var.compartment_id
  name               = "${var.project_name}-oke"
  kubernetes_version = var.oke_kubernetes_version
  vcn_id             = module.vcn.vcn_id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.public.id
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.public.id]
  }
}

resource "oci_containerengine_node_pool" "node_pool" {
  compartment_id     = var.compartment_id
  cluster_id         = oci_containerengine_cluster.oke.id
  kubernetes_version = var.oke_kubernetes_version
  name               = "${var.project_name}-nodepool"

  node_shape = var.oke_node_shape

  node_config_details {
    size = var.oke_node_count

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.private_workers.id
    }
  }

  initial_node_labels {
    key   = "environment"
    value = var.environment
  }

  node_shape_config {
    ocpus         = var.oke_node_ocpus
    memory_in_gbs = var.oke_node_memory_gb
  }
}
# ============================================================
# NOSQL (DynamoDB equivalent)
# ============================================================

resource "oci_nosql_table" "main" {
  compartment_id = var.compartment_id

  name = "${replace(var.project_name, "-", "_")}_table"

  ddl_statement = <<EOT
CREATE TABLE ${replace(var.project_name, "-", "_")}_table (
  id STRING,
  PRIMARY KEY (id)
)
EOT

  table_limits {
    max_read_units     = var.nosql_read_units
    max_write_units    = var.nosql_write_units
    max_storage_in_gbs = var.nosql_storage_gb
  }
}

# ============================================================
# QUEUE (SQS equivalent)
# ============================================================

resource "oci_queue_queue" "dlq" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-dlq"
}

resource "oci_queue_queue" "main" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-queue"

  retention_in_seconds = var.queue_retention_seconds
}