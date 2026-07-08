module "networking" {
  source         = "./modules/networking"
  compartment_id = var.compartment_id
  tags           = var.common_tags
}

module "ocir" {
  source = "./modules/ocir"
  # OCIR repos sao criados no compartment RAIZ (tenancy), que e onde o
  # `docker push` os cria automaticamente. Usar o mesmo compartment garante que
  # o import abaixo os adote em vez de tentar recria-los (409-NAMESPACE_CONFLICT).
  compartment_id = var.tenancy_ocid
  tags           = var.common_tags
}

module "nosql" {
  source = "./modules/nosql"

  compartment_id = var.compartment_id
  table_name     = "togglemaster_table"
  tags           = var.common_tags
}

module "queue" {
  source = "./modules/queue"

  compartment_id = var.compartment_id
  tags           = var.common_tags
}

module "oke" {
  source = "./modules/oke"

  compartment_id      = var.compartment_id
  tenancy_ocid        = var.tenancy_ocid
  vcn_id              = module.networking.vcn_id
  subnet_id           = module.networking.workers_subnet_id
  availability_domain = var.availability_domain
  node_image          = var.oke_image
  node_subnet_id      = module.networking.node_subnet_id
  lb_subnet_id        = module.networking.lb_subnet_id
  tags                = var.common_tags
}

module "observability" {
  source               = "./modules/observability"
  cluster_id           = module.oke.cluster_id
  redis_host           = "redis.togglemaster.svc.cluster.local"
  namespace            = "monitoring"
  discord_webhook_url  = var.discord_webhook_url
  newrelic_license_key = var.newrelic_license_key

  depends_on = [module.oke]
}

# ---------------------------------------------------------------------------
# One-off import — the OCIR state was lost/recreated but the repos still
# exist in OCI, so `apply` was hitting 409-NAMESPACE_CONFLICT trying to
# recreate them. These bring the existing repos back under Terraform
# management instead of creating duplicates. Safe to delete this block once
# `terraform state list` shows the three module.ocir resources as tracked.
# ---------------------------------------------------------------------------
data "oci_artifacts_container_repositories" "existing_ngo_service" {
  compartment_id = var.tenancy_ocid
  display_name   = "hackathon-repo/ngo-service"
}

data "oci_artifacts_container_repositories" "existing_donation_service" {
  compartment_id = var.tenancy_ocid
  display_name   = "hackathon-repo/donation-service"
}

data "oci_artifacts_container_repositories" "existing_volunteer_service" {
  compartment_id = var.tenancy_ocid
  display_name   = "hackathon-repo/volunteer-service"
}

import {
  for_each = toset(try([data.oci_artifacts_container_repositories.existing_ngo_service.container_repository_collection[0].items[0].id], []))
  to       = module.ocir.oci_artifacts_container_repository.ngo_service
  id       = each.value
}

import {
  for_each = toset(try([data.oci_artifacts_container_repositories.existing_donation_service.container_repository_collection[0].items[0].id], []))
  to       = module.ocir.oci_artifacts_container_repository.donation_service
  id       = each.value
}

import {
  for_each = toset(try([data.oci_artifacts_container_repositories.existing_volunteer_service.container_repository_collection[0].items[0].id], []))
  to       = module.ocir.oci_artifacts_container_repository.volunteer_service
  id       = each.value
}
