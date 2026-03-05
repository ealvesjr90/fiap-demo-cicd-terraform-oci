resource "oci_nosql_table" "demo" {
  compartment_id = var.compartment_id
  name           = "demo-table"
  ddl_statement  = "CREATE TABLE demo(id STRING, PRIMARY KEY(id))"
}