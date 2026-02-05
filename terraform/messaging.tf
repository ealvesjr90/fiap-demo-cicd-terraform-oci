# ============================================================
# MESSAGING - OCI Queue Service
# ============================================================
# Equivalente AWS: SQS (Simple Queue Service)

# 🎯 LIVE: Descomentar este arquivo para criar a fila de mensagens

# ✅ OCI Queue tem FREE TIER: 1M mensagens/mês
# ============================================================

# -----------------------------------------------------
# OCI Queue - Fila Principal
# -----------------------------------------------------
resource "oci_queue_queue" "main" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-queue"

  # Configurações da fila
  dead_letter_queue_delivery_count = var.queue_dead_letter_count
  retention_in_seconds             = var.queue_retention_seconds
  timeout_in_seconds               = var.queue_timeout_seconds
  visibility_in_seconds            = var.queue_visibility_seconds

  # Tamanho máximo da mensagem (bytes)
  custom_encryption_key_id = null # Usar chave gerenciada pela OCI

  freeform_tags = {
    "Environment" = var.environment
    "Project"     = var.project_name
    "Service"     = "messaging"
  }
}

# -----------------------------------------------------
# OCI Queue - Dead Letter Queue (DLQ)
# -----------------------------------------------------
resource "oci_queue_queue" "dlq" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-queue-dlq"

  # DLQ tem retenção maior para análise de erros
  retention_in_seconds  = 604800 # 7 dias (máximo permitido)
  timeout_in_seconds    = 30
  visibility_in_seconds = 30

  freeform_tags = {
    "Environment" = var.environment
    "Project"     = var.project_name
    "Service"     = "messaging"
    "Type"        = "dead-letter-queue"
  }
}
