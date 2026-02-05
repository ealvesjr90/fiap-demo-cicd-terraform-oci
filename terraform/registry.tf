# ============================================================
# REGISTRY - OCI Container Registry (OCIR)
# ============================================================
# Equivalente AWS: ECR (Elastic Container Registry)

# 🎯 LIVE: Descomentar este arquivo para criar os repositórios

# ✅ OCIR tem FREE TIER: 500MB de storage

# Repositórios para os 5 microserviços:
# 1. api-gateway
# 2. user-service
# 3. order-service
# 4. payment-service
# 5. notification-service
# ============================================================

# -----------------------------------------------------
# Container Repository 1 - API Gateway
# -----------------------------------------------------
resource "oci_artifacts_container_repository" "api_gateway" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}/api-gateway"
  is_public      = false
  is_immutable   = false

  readme {
    content = "API Gateway service container images"
    format  = "text/plain"
  }
}

# -----------------------------------------------------
# Container Repository 2 - User Service
# -----------------------------------------------------
resource "oci_artifacts_container_repository" "user_service" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}/user-service"
  is_public      = false
  is_immutable   = false

  readme {
    content = "User service container images"
    format  = "text/plain"
  }
}

# -----------------------------------------------------
# Container Repository 3 - Order Service
# -----------------------------------------------------
resource "oci_artifacts_container_repository" "order_service" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}/order-service"
  is_public      = false
  is_immutable   = false

  readme {
    content = "Order service container images"
    format  = "text/plain"
  }
}

# -----------------------------------------------------
# Container Repository 4 - Payment Service
# -----------------------------------------------------
resource "oci_artifacts_container_repository" "payment_service" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}/payment-service"
  is_public      = false
  is_immutable   = false

  readme {
    content = "Payment service container images"
    format  = "text/plain"
  }
}

# -----------------------------------------------------
# Container Repository 5 - Notification Service
# -----------------------------------------------------
resource "oci_artifacts_container_repository" "notification_service" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}/notification-service"
  is_public      = false
  is_immutable   = false

  readme {
    content = "Notification service container images"
    format  = "text/plain"
  }
}

# ============================================================
# COMO FAZER PUSH PARA O OCIR
# ============================================================
#
# 1. Login no OCIR:
#    docker login <region>.ocir.io -u '<namespace>/<username>'
#    Exemplo: docker login sa-vinhedo-1.ocir.io -u 'ax7pefxfpuix/oracleidentitycloudservice/jose@email.com'
#    Password: Auth Token (gerar em User Settings > Auth Tokens)
#
# 2. Tag da imagem:
#    docker tag myapp:latest <region>.ocir.io/<namespace>/<repo>:<tag>
#    Exemplo: docker tag myapp:latest sa-vinhedo-1.ocir.io/ax7pefxfpuix/fiap-demo/api-gateway:v1.0.0
#
# 3. Push:
#    docker push <region>.ocir.io/<namespace>/<repo>:<tag>
#
# ============================================================
