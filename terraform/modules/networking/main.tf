resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_id
  cidr_block     = "10.0.0.0/16"
  display_name   = "togglemaster-vcn"
}

resource "oci_core_subnet" "workers" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  cidr_block     = "10.0.3.0/24"
  display_name   = "workers-subnet"
}

resource "oci_core_subnet" "db" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  cidr_block     = "10.0.5.0/24"
  display_name   = "db-subnet"
}