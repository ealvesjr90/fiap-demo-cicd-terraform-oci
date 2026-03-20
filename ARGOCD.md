# 🔄 ArgoCD — GitOps Deployment Guide

Guia completo para instalar o ArgoCD no cluster OKE e testar os deploys dos serviços ToggleMaster.

---

## 📋 Pré-requisitos

- Cluster OKE provisionado (veja [HANDS-ON.md](HANDS-ON.md))
- `kubectl` configurado apontando para o cluster
- `argocd` CLI instalado (instruções abaixo)

---

## 🚀 PARTE 1: Instalar o ArgoCD no Cluster

### Passo 1: Criar o namespace e instalar o ArgoCD

```bash
kubectl create namespace argocd

kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Passo 2: Aguardar os pods ficarem prontos

```bash
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
```

### Passo 3: Expor o servidor do ArgoCD (LoadBalancer)

```bash
kubectl patch svc argocd-server -n argocd \
  -p '{"spec": {"type": "LoadBalancer"}}'

# Aguardar o IP externo ser atribuído
kubectl get svc argocd-server -n argocd --watch
```

Copie o **EXTERNAL-IP** exibido (ex: `xxx.xxx.xxx.xxx`).

---

## 🔑 PARTE 2: Fazer Login no ArgoCD

### Passo 1: Instalar o ArgoCD CLI

**Mac (Homebrew):**
```bash
brew install argocd
```

**Linux:**
```bash
curl -sSL -o /usr/local/bin/argocd \
  https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```

**Windows (Scoop):**
```powershell
scoop install argocd
```

### Passo 2: Obter a senha inicial

```bash
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)
echo "Senha: ${ARGOCD_PASSWORD}"
```

### Passo 3: Fazer login

```bash
# Substitua pelo EXTERNAL-IP do passo anterior
ARGOCD_SERVER="xxx.xxx.xxx.xxx"

argocd login "${ARGOCD_SERVER}" \
  --username admin \
  --password "${ARGOCD_PASSWORD}" \
  --insecure
```

### Passo 4: Alterar a senha (recomendado)

```bash
argocd account update-password \
  --current-password "${ARGOCD_PASSWORD}" \
  --new-password "SuaNovaSenha@123"
```

---

## 📦 PARTE 3: Registrar o Repositório GitHub no ArgoCD

Se o repositório for **público**, pule este passo.

Para repositório **privado**:

```bash
argocd repo add https://github.com/ealvesjr90/fiap-demo-cicd-terraform-oci \
  --username git \
  --password ghp_SEU_PERSONAL_ACCESS_TOKEN
```

---

## 🏗️ PARTE 4: Aplicar os Manifestos ArgoCD

### Passo 1: Criar o AppProject

```bash
kubectl apply -f argocd/project.yaml
```

### Passo 2: Criar o App-of-Apps (cria todos os serviços automaticamente)

```bash
kubectl apply -f argocd/app-of-apps.yaml
```

O ArgoCD vai detectar os arquivos em `argocd/applications/` e criar uma
`Application` para cada serviço.

### Verificar as aplicações criadas

```bash
argocd app list
```

Saída esperada:

```
NAME                CLUSTER                         NAMESPACE     PROJECT       STATUS  HEALTH   SYNCPOLICY  ...
analytics-service   https://kubernetes.default.svc  togglemaster  togglemaster  Synced  Healthy  Auto        ...
auth-service        https://kubernetes.default.svc  togglemaster  togglemaster  Synced  Healthy  Auto        ...
evaluation-service  https://kubernetes.default.svc  togglemaster  togglemaster  Synced  Healthy  Auto        ...
flag-service        https://kubernetes.default.svc  togglemaster  togglemaster  Synced  Healthy  Auto        ...
targeting-service   https://kubernetes.default.svc  togglemaster  togglemaster  Synced  Healthy  Auto        ...
togglemaster-apps   https://kubernetes.default.svc  argocd        default       Synced  Healthy  Auto        ...
```

---

## 🧪 PARTE 5: Testar os Deploys com ArgoCD

### 5.1 — Verificar status de uma aplicação

```bash
argocd app get analytics-service
```

Campos importantes:
- **Health Status:** `Healthy` ✅ ou `Degraded` ❌
- **Sync Status:** `Synced` ✅ ou `OutOfSync` ⚠️

### 5.2 — Forçar sincronização manual

```bash
argocd app sync analytics-service
```

### 5.3 — Aguardar sincronização completar

```bash
argocd app wait analytics-service --sync --health --timeout 300
```

### 5.4 — Verificar histórico de deploys

```bash
argocd app history analytics-service
```

### 5.5 — Verificar diff entre git e cluster

```bash
argocd app diff analytics-service
```

### 5.6 — Fazer rollback para revisão anterior

```bash
# Listar histórico
argocd app history analytics-service

# Rollback para ID específico (ex: ID 2)
argocd app rollback analytics-service 2
```

### 5.7 — Verificar todas as aplicações de uma vez

```bash
for APP in analytics-service auth-service evaluation-service flag-service targeting-service; do
  echo -n "▶ ${APP}: "
  argocd app get "${APP}" --output json | \
    python3 -c "import sys,json; d=json.load(sys.stdin); \
    print(f\"Health={d['status']['health']['status']} | Sync={d['status']['sync']['status']}\")"
done
```

---

## 🖥️ PARTE 6: Acessar a UI do ArgoCD

1. Abra o navegador em: `https://<EXTERNAL-IP>`
2. Usuário: `admin`
3. Senha: a que você definiu no Passo 4 da PARTE 2

Na interface, você pode:
- 👁️ Visualizar o grafo de recursos de cada aplicação
- 🔄 Sincronizar manualmente
- ⏪ Fazer rollback
- 📋 Ver logs dos pods

---

## 🔧 PARTE 7: Configurar Secrets GitHub Actions para o Sync Check

Após o deploy de um serviço via GitHub Actions, o workflow verifica
automaticamente se o ArgoCD sincronizou a aplicação.

Para isso, configure estes secrets no repositório GitHub:

**Settings → Secrets and variables → Actions → New repository secret**

| Secret | Valor |
|--------|-------|
| `ARGOCD_SERVER` | IP ou hostname do servidor ArgoCD (sem `https://`) |
| `ARGOCD_AUTH_TOKEN` | Token de autenticação (veja abaixo) |

### Gerar o token de autenticação do ArgoCD

```bash
# Gerar um token para a conta admin (válido indefinidamente, ou com --expires-in)
argocd account generate-token --account admin
```

Copie o token gerado e salve como secret `ARGOCD_AUTH_TOKEN`.

> **Boa prática:** crie uma conta dedicada para o GitHub Actions editando o
> ConfigMap `argocd-cm` e adicionando `accounts.github-actions: apiKey`.
> Em seguida, gere o token com:
> ```bash
> argocd account generate-token --account github-actions
> ```

---

## 🔄 Fluxo Completo CI/CD + ArgoCD

```
Developer → git push → GitHub Actions
                            │
                    ┌───────┴───────┐
                    │  1. Lint/Test  │
                    │  2. Sec Scan  │
                    │  3. Build img │
                    │  4. Push OCIR │
                    └───────┬───────┘
                            │
                    ┌───────┴───────┐
                    │ 5. Update     │  ← Atualiza image tag
                    │    GitOps     │    no deployment.yaml
                    └───────┬───────┘
                            │ git push → main
                            │
                    ┌───────┴───────┐
                    │ ArgoCD detecta│  ← Polling a cada 3 min
                    │  mudança      │    ou webhook
                    └───────┬───────┘
                            │
                    ┌───────┴───────┐
                    │ ArgoCD Sync   │  ← Aplica novos manifests
                    │ no cluster    │    no OKE
                    └───────┬───────┘
                            │
                    ┌───────┴───────┐
                    │ 6. Sync Check │  ← GitHub Actions verifica
                    │  (GH Actions) │    health e sync status
                    └───────────────┘
```

---

## 🐛 Troubleshooting

| Problema | Diagnóstico | Solução |
|----------|-------------|---------|
| `OutOfSync` | `argocd app diff <nome>` | `argocd app sync <nome>` |
| `Degraded` | `kubectl describe pod -n togglemaster` | Verificar imagem/secrets |
| `imagePullBackOff` | Logs do pod | Verificar `ocir-secret` e credenciais OCIR |
| `CrashLoopBackOff` | `kubectl logs <pod> -n togglemaster` | Verificar variáveis de ambiente |
| ArgoCD não detecta mudança | `argocd app get <nome>` | `argocd app sync <nome> --force` |
| Login com token falha | — | Regenerar token com `argocd account generate-token` |

---

## 📚 Recursos

- [ArgoCD Docs](https://argo-cd.readthedocs.io/)
- [ArgoCD CLI Reference](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd/)
- [App-of-Apps Pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/)
- [OKE + ArgoCD](https://docs.oracle.com/en/learn/oke-argocd/)
