# Homelab Integration Guide: rita-v2-baseapp-02

This document provides the necessary artifacts and instructions to deploy the `rita-v2-baseapp-02` and its observability stack to the `rita-pve02` homelab.

---

## 🤖 Prompt for Coding Agent

*Copy and paste the following prompt to a coding agent (like Jules) to automate the integration:*

> "I have a NestJS base application (rita-v2-baseapp-02) and I need to integrate its deployment into my homelab (rita-pve02).
>
> **Tasks:**
> 1. Create an ArgoCD Application for the **Observability Stack** (located in `charts/observability-stack` of the baseapp repo). It should be deployed to the `monitoring` namespace on the control plane.
> 2. Create an ArgoCD Application for the **Base App** (located in `charts/rita-v2-baseapp-02`). It should be deployed to the `rita-apps` namespace.
> 3. Configure **ExternalSecrets** for the Base App. I use 1Password and the ExternalSecrets Operator. The secret in 1Password is named `rita-baseapp-secrets`.
> 4. Ensure the Base App points to the unified OTEL Collector at `otel-collector.monitoring.svc.cluster.local`.
> 5. Set up a shared Postgres instance if one doesn't exist, or point the app to the existing one at `postgres.database.svc.cluster.local`.
>
> Please generate the necessary K8s manifests and update the homelab's Ansible playbooks if required to support these namespaces and operators."

---

## 📦 Integration Artifacts

### 1. ArgoCD: Observability Stack
Deploy this once to your cluster to provide centralized logging, tracing, and metrics.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: observability-stack
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/SiderealMollusk/rita-baseapp-01.git
    targetRevision: main
    path: charts/observability-stack
  destination:
    server: https://kubernetes.default.svc
    namespace: monitoring
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### 2. ArgoCD: Base App
Deploy your application and connect it to the observability stack.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: rita-v2-baseapp-02
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/SiderealMollusk/rita-baseapp-01.git
    targetRevision: main
    path: charts/rita-v2-baseapp-02
    helm:
      values: |
        externalSecrets:
          enabled: true
          secretStoreName: "1password-vault"
          remoteRef:
            key: "rita-baseapp-secrets"
        otel:
          exporter:
            traces:
              endpoint: "http://otel-collector.monitoring.svc.cluster.local:4318/v1/traces"
            metrics:
              endpoint: "http://otel-collector.monitoring.svc.cluster.local:4318/v1/metrics"
        ingress:
          enabled: true
          hosts:
            - host: baseapp.homelab.local
              paths:
                - path: /
                  pathType: ImplementationSpecific
  destination:
    server: https://kubernetes.default.svc
    namespace: rita-apps
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

---

## 🔐 Secret Management

The app is configured to use the **ExternalSecrets Operator**.

### Step 1: Create the Secret in 1Password
Create a login or password item named `rita-baseapp-secrets` with the following fields:
- `DATABASE_USER`
- `DATABASE_PASSWORD`
- `DATABASE_NAME`
- `JWT_SECRET`
- `SUPABASE_URL`
- `SUPABASE_KEY`

### Step 2: Injecting via CLI (Dev Mode)
If you are running locally or in a dev container, use the `op` CLI as suggested:
```bash
op run -- env $(cat .env.dist) npm run start:dev
```

---

## 🗄️ Database Strategy

If you don't have a shared Postgres yet, you can add one via Bitnami's Helm chart:
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install postgres bitnami/postgresql --namespace database --create-namespace
```
Then update the `database.host` in the Base App's `values.yaml` to `postgres.database.svc.cluster.local`.

---

## 📡 Connectivity Summary

| Component | Internal URL | External (Ingress) |
|-----------|--------------|-------------------|
| Grafana | `grafana.monitoring.svc:3000` | `grafana.homelab.local` |
| OTEL Collector | `otel-collector.monitoring.svc:4318` | N/A |
| Base App | `rita-v2-baseapp-02.rita-apps.svc:80` | `baseapp.homelab.local` |
