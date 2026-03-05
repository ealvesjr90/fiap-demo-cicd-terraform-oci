module "ocir" {
  source         = "./modules/ocir"
  compartment_id = var.compartment_id
}