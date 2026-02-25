resource "oci_nosql_table" "analytics" {
  compartment_id = var.compartment_id
  name           = "ToggleMasterAnalytics"
}