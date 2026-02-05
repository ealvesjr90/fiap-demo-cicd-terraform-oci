# ============================================================
# REDIS - OCI Cache with Redis
# ============================================================
# Equivalente AWS: ElastiCache Redis
#
# 🎯 LIVE: Descomentar este arquivo para criar o cache Redis
#
# ⚠️ NOTA: OCI Cache with Redis é um serviço PAGO
# Alternativa Free Tier: Deploy Redis como container no OKE
# ============================================================

# # -----------------------------------------------------
# # OCI Cache with Redis - Cluster
# # -----------------------------------------------------
# resource "oci_redis_redis_cluster" "main" {
#   compartment_id = var.compartment_id
#   display_name   = "${var.project_name}-redis"
#
#   # Configuração do cluster
#   node_count      = var.redis_node_count
#   node_memory_in_gbs = var.redis_node_memory_gb
#   software_version   = var.redis_version
#
#   # Rede
#   subnet_id = oci_core_subnet.private_1.id
#
#   freeform_tags = {
#     "Environment" = var.environment
#     "Project"     = var.project_name
#     "Service"     = "cache"
#   }
# }

# # ============================================================
# # ALTERNATIVA FREE TIER: Redis no Kubernetes
# # ============================================================
# # Se preferir não pagar pelo OCI Cache, use este Kubernetes
# # manifest para deploy do Redis no OKE:
# #
# # kubectl apply -f - <<EOF
# # apiVersion: apps/v1
# # kind: Deployment
# # metadata:
# #   name: redis
# # spec:
# #   replicas: 1
# #   selector:
# #     matchLabels:
# #       app: redis
# #   template:
# #     metadata:
# #       labels:
# #         app: redis
# #     spec:
# #       containers:
# #       - name: redis
# #         image: redis:7-alpine
# #         ports:
# #         - containerPort: 6379
# #         resources:
# #           requests:
# #             memory: "256Mi"
# #             cpu: "100m"
# #           limits:
# #             memory: "512Mi"
# #             cpu: "500m"
# # ---
# # apiVersion: v1
# # kind: Service
# # metadata:
# #   name: redis
# # spec:
# #   selector:
# #     app: redis
# #   ports:
# #   - port: 6379
# #     targetPort: 6379
# # EOF
# # ============================================================
