resource "oci_containerengine_cluster" "oke" {
  compartment_id     = var.compartment_id
  name               = "techchallenge-oke"
  vcn_id             = var.vcn_id
  kubernetes_version = "v1.28.2"
}

resource "oci_containerengine_node_pool" "pool" {
  cluster_id     = oci_containerengine_cluster.oke.id
  compartment_id = var.compartment_id
  name           = "nodepool"

  node_config_details {
    size = 2
  }

  node_shape = "VM.Standard.E4.Flex"
}

output "cluster_id" {
  value = oci_containerengine_cluster.oke.id
}