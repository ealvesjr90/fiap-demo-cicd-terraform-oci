resource "oci_core_instance" "postgres" {
  count               = 3
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.E4.Flex"
  display_name        = "postgres-${count.index}"
}