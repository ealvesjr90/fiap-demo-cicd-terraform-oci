resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.7.1"

  wait         = true
  wait_for_jobs = true
  timeout      = 600

  values = [<<EOF
global:
  image:
    repository: quay.io/argoproj/argocd
    tag: ""

configs:
  cm:
    application.resourceTrackingMethod: annotation
    timeout.reconciliation: 180s
    resource.exclusions: |
      - apiGroups:
          - cilium.io
        kinds:
          - CiliumIdentity
        clusters:
          - "*"
  params:
    server.insecure: true
  rbac:
    policy.default: role:readonly
    policy.csv: |
      p, role:admin, applications, *, */*, allow
      p, role:admin, clusters, get, *, allow
      p, role:admin, repositories, get, *, allow
      p, role:admin, repositories, create, *, allow
      p, role:admin, repositories, update, *, allow
      p, role:admin, repositories, delete, *, allow
      g, argocd-admins, role:admin

controller:
  replicas: 1
  resources:
    requests:
      cpu: 250m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi
  metrics:
    enabled: false

dex:
  enabled: true
  resources:
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 100m
      memory: 128Mi

redis:
  enabled: true
  resources:
    requests:
      cpu: 100m
      memory: 64Mi
    limits:
      cpu: 200m
      memory: 128Mi

server:
  replicas: 1
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 200m
      memory: 256Mi
  service:
    type: LoadBalancer
    annotations:
      service.beta.kubernetes.io/oci-load-balancer-shape: flexible
      # Minimum bandwidth in Mbps for the OCI flexible load balancer
      service.beta.kubernetes.io/oci-load-balancer-shape-flex-min: "10"
      # Maximum bandwidth in Mbps for the OCI flexible load balancer
      service.beta.kubernetes.io/oci-load-balancer-shape-flex-max: "100"
  metrics:
    enabled: false

repoServer:
  replicas: 1
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 200m
      memory: 256Mi
  metrics:
    enabled: false

applicationSet:
  enabled: true
  replicas: 1
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 200m
      memory: 256Mi
  metrics:
    enabled: false

notifications:
  enabled: true
  resources:
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 100m
      memory: 128Mi
  metrics:
    enabled: false
EOF
  ]
}

resource "kubectl_manifest" "argocd_apps" {
  for_each = toset([
    "auth-service",
    "flag-service",
    "targeting-service",
    "evaluation-service",
    "analytics-service"
  ])

  yaml_body = <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${each.key}
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/ealvesjr90/fiap-demo-cicd-terraform-oci.git
    targetRevision: main
    path: ${each.key}/k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: togglemaster
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF

  depends_on = [helm_release.argocd]
}