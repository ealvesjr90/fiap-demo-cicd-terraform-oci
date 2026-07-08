# =============================================================================
# Ambiente DR (Disaster Recovery) - Warm Standby / Ativo-Passivo
# =============================================================================
# Regiao secundaria (espelho) da regiao primaria sa-saopaulo-1.
# Aplicar SEMPRE no workspace "dr" para isolar o state:
#
#   terraform workspace select dr || terraform workspace new dr
#   terraform apply -var-file=envs/dr.tfvars
#
# Ou use o comando unico: ./scripts/dr-standby.sh apply
# -----------------------------------------------------------------------------

region = "sa-vinhedo-1"

# Compartments no OCI sao globais (nao regionais), entao usamos o mesmo da primaria.
compartment_id = "ocid1.compartment.oc1..aaaaaaaanehxovyxoaobjbxqhbgdcubarphs5xuptwok4gbcpepxov75obpq"

# Informativo apenas: o modulo OKE resolve o AD e a imagem dos nodes
# dinamicamente (data sources), entao estes campos nao precisam de OCID por regiao.
availability_domain = "Uocm:SA-VINHEDO-1-AD-1"
