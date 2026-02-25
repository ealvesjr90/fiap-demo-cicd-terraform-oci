resource "oci_queue_queue" "main" {
  compartment_id = var.compartment_id
  display_name   = "techchallenge-queue"
}