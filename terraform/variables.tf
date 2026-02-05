variable "tenancy_ocid" {
  description = "OCID do Tenancy OCI"
  type        = string
  sensitive   = true
}

variable "user_ocid" {
  description = "OCID do Usuário OCI"
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "Fingerprint da API Key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Região OCI"
  type        = string
  default     = "us-ashburn-1"
}

variable "compartment_id" {
  description = "OCID do Compartment"
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.(compartment|tenancy)\\.oc1\\..", var.compartment_id))
    error_message = "O compartment_id deve ser um OCID válido (ocid1.compartment.oc1... ou ocid1.tenancy.oc1...)."
  }
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "demo"
}

variable "environment" {
  description = "Ambiente (dev/staging/prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "O environment deve ser: dev, staging ou prod."
  }
}

variable "instance_count" {
  description = "Número de instâncias"
  type        = number
  default     = 2

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 4
    error_message = "O instance_count deve ser entre 1 e 4 (Free Tier)."
  }
}

variable "vcn_cidr" {
  description = "CIDR block da VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block da subnet pública"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_shape" {
  description = "Shape da instância (Free Tier: VM.Standard.E2.1.Micro)"
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "instance_image_id" {
  description = "OCID da imagem Oracle Linux"
  type        = string
}

variable "ssh_public_key" {
  description = "Chave SSH pública"
  type        = string
  sensitive   = true
}

variable "ingress_ports" {
  description = "Portas TCP de ingress permitidas na security list"
  type        = list(number)
  default     = [22, 80]
}

# ============================================================
# 🎯 LIVE: Descomentar as variáveis abaixo conforme necessário
# ============================================================

# # -----------------------------------------------------
# # NETWORKING - Subnets adicionais
# # -----------------------------------------------------
# variable "subnet_public_1_cidr" {
#   description = "CIDR da subnet pública 1"
#   type        = string
#   default     = "10.0.1.0/24"
# }

# variable "subnet_public_2_cidr" {
#   description = "CIDR da subnet pública 2"
#   type        = string
#   default     = "10.0.2.0/24"
# }

# variable "subnet_private_1_cidr" {
#   description = "CIDR da subnet privada 1"
#   type        = string
#   default     = "10.0.10.0/24"
# }

# variable "subnet_private_2_cidr" {
#   description = "CIDR da subnet privada 2"
#   type        = string
#   default     = "10.0.11.0/24"
# }

# # -----------------------------------------------------
# # OKE - Oracle Kubernetes Engine
# # -----------------------------------------------------
# variable "oke_kubernetes_version" {
#   description = "Versão do Kubernetes para o OKE"
#   type        = string
#   default     = "v1.34.1"
# }

# variable "oke_node_shape" {
#   description = "Shape dos nodes do OKE"
#   type        = string
#   default     = "VM.Standard.E4.Flex"
# }

# variable "oke_node_ocpus" {
#   description = "Número de OCPUs por node"
#   type        = number
#   default     = 2
# }

# variable "oke_node_memory_gb" {
#   description = "Memória em GB por node"
#   type        = number
#   default     = 16
# }

# variable "oke_node_count" {
#   description = "Número de nodes no pool"
#   type        = number
#   default     = 2
# }

# variable "oke_node_image_id" {
#   description = "OCID da imagem para os nodes OKE"
#   type        = string
# }

# variable "oke_pods_cidr" {
#   description = "CIDR para pods do Kubernetes"
#   type        = string
#   default     = "10.244.0.0/16"
# }

# variable "oke_services_cidr" {
#   description = "CIDR para services do Kubernetes"
#   type        = string
#   default     = "10.96.0.0/16"
# }

# # -----------------------------------------------------
# # DATABASES - PostgreSQL (Autonomous Database)
# # -----------------------------------------------------
# variable "db_is_free_tier" {
#   description = "Usar Free Tier para o banco (limite: 2 databases)"
#   type        = bool
#   default     = true
# }

# variable "db_cpu_core_count" {
#   description = "Número de CPUs do database"
#   type        = number
#   default     = 1
# }

# variable "db_storage_size_tb" {
#   description = "Tamanho do storage em TB"
#   type        = number
#   default     = 1
# }

# variable "db_admin_password" {
#   description = "Senha do admin do database (min 12 chars, 1 upper, 1 lower, 1 number)"
#   type        = string
#   sensitive   = true
# }

# # -----------------------------------------------------
# # REDIS - OCI Cache with Redis
# # -----------------------------------------------------
# variable "redis_node_count" {
#   description = "Número de nodes do Redis cluster"
#   type        = number
#   default     = 1
# }

# variable "redis_node_memory_gb" {
#   description = "Memória em GB por node Redis"
#   type        = number
#   default     = 2
# }

# variable "redis_version" {
#   description = "Versão do Redis"
#   type        = string
#   default     = "REDIS_7_0"
# }

# # -----------------------------------------------------
# # NOSQL - OCI NoSQL Database (equivalente DynamoDB)
# # -----------------------------------------------------
# variable "nosql_read_units" {
#   description = "Unidades de leitura máximas"
#   type        = number
#   default     = 50
# }

# variable "nosql_write_units" {
#   description = "Unidades de escrita máximas"
#   type        = number
#   default     = 50
# }

# variable "nosql_storage_gb" {
#   description = "Storage máximo em GB"
#   type        = number
#   default     = 25
# }

# # -----------------------------------------------------
# # QUEUE - OCI Queue Service (equivalente SQS)
# # -----------------------------------------------------
# variable "queue_retention_seconds" {
#   description = "Tempo de retenção das mensagens em segundos"
#   type        = number
#   default     = 345600 # 4 dias
# }

# variable "queue_timeout_seconds" {
#   description = "Timeout para processamento da mensagem"
#   type        = number
#   default     = 30
# }

# variable "queue_visibility_seconds" {
#   description = "Tempo de visibilidade da mensagem"
#   type        = number
#   default     = 30
# }

# variable "queue_dead_letter_count" {
#   description = "Número de tentativas antes de enviar para DLQ"
#   type        = number
#   default     = 5
# }
