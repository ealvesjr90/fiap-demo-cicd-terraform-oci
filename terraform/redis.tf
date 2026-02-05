# ============================================================
# REDIS - OCI Cache with Redis
# ============================================================
# Equivalente AWS: ElastiCache Redis

# 🎯 LIVE: Descomentar este arquivo para criar o cache Redis

# ⚠️ NOTA: OCI Cache with Redis é um serviço PAGO
# Alternativa Free Tier: Deploy Redis como container no OKE
# ============================================================

# -----------------------------------------------------
# OCI Cache with Redis - Cluster
# -----------------------------------------------------
resource "oci_redis_redis_cluster" "main" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-redis"

  # Configuração do cluster
  node_count      = var.redis_node_count
  node_memory_in_gbs = var.redis_node_memory_gb
  software_version   = var.redis_version

  # Rede - usando subnet de databases da VCN OKE
  subnet_id = oci_core_subnet.oke_db.id

  freeform_tags = {
    "Environment" = var.environment
    "Project"     = var.project_name
    "Service"     = "cache"
  }
}
