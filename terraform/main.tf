terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.6.0"

  compartment_id = var.compartment_id
  region         = var.region
  
  vcn_name      = "${var.project_name}-vcn"
  vcn_dns_label = replace("${var.project_name}vcn", "-", "")
  vcn_cidrs     = ["10.0.0.0/16"]
  
  create_internet_gateway = true
  create_nat_gateway      = false
  create_service_gateway  = false
}

module "subnet" {
  source  = "oracle-terraform-modules/vcn/oci//modules/subnet"
  version = "3.6.0"

  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  
  cidr_block     = "10.0.1.0/24"
  display_name   = "${var.project_name}-public-subnet"
  dns_label      = "public"
  route_table_id = module.vcn.ig_route_id
  
  security_list_ids = [module.vcn.vcn_all_attributes.default_security_list_id]
}

module "compute" {
  source  = "oracle-terraform-modules/compute-instance/oci"
  version = "2.4.0"

  compartment_ocid      = var.compartment_id
  instance_count        = var.instance_count
  ad_number             = 1
  instance_display_name = "${var.project_name}-instance"
  
  source_type = "image"
  source_ocid = var.instance_image_id
  
  subnet_ocids = [module.subnet.subnet_id]
  shape        = "VM.Standard.E2.1.Micro"
  
  ssh_public_keys = var.ssh_public_key

  depends_on = [module.subnet]
}
