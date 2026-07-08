#!/usr/bin/env bash
# =============================================================================
# DR Warm Standby (Opcao B - Ativo-Passivo)
# =============================================================================
# Sobe / atualiza / remove o ambiente espelho na regiao secundaria
# (sa-vinhedo-1) com UM comando, usando um workspace Terraform dedicado ("dr")
# para isolar o state do ambiente primario.
#
# Uso:
#   ./scripts/dr-standby.sh plan      # (padrao) mostra o plano do DR
#   ./scripts/dr-standby.sh apply     # provisiona/atualiza o warm standby
#   ./scripts/dr-standby.sh destroy   # remove o ambiente DR
#   ./scripts/dr-standby.sh output    # mostra os outputs do DR
#
# Pre-requisitos: credenciais OCI configuradas (variaveis TF_VAR_* ou ~/.oci).
# =============================================================================
set -euo pipefail

ACTION="${1:-plan}"
WORKSPACE="dr"
VAR_FILE="envs/dr.tfvars"

cd "$(dirname "$0")/../terraform"

terraform init -input=false

# Garante o workspace isolado do DR
terraform workspace select "$WORKSPACE" 2>/dev/null || terraform workspace new "$WORKSPACE"
echo "==> Terraform workspace: $(terraform workspace show)"

case "$ACTION" in
  plan)
    terraform plan -var-file="$VAR_FILE" -input=false
    ;;
  apply)
    terraform apply -var-file="$VAR_FILE" -input=false -auto-approve
    ;;
  destroy)
    terraform destroy -var-file="$VAR_FILE" -input=false -auto-approve
    ;;
  output)
    terraform output
    ;;
  *)
    echo "Acao invalida: $ACTION (use: plan | apply | destroy | output)" >&2
    exit 1
    ;;
esac
