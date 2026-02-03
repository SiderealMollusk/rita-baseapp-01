# rita-v2-baseapp-02

A modern, production-ready Kubernetes-native base template for NestJS applications. Built for homelabs and focused on high-end observability and clean architecture.

## 🚀 Overview

This repository provides a "Zero to Hero" template for microservices. It combines the power of **NestJS**, **Effect-TS** (Functional Programming), and **OpenTelemetry** with a ready-to-use Kubernetes deployment strategy.

### Key Technologies
- **Backend:** NestJS with Fastify (High Performance)
- **Architecture:** DDD + Clean Architecture + Modular Monolith
- **Logic:** Effect-TS for type-safe, functional error handling
- **Observability:** OpenTelemetry SDK, Prometheus, Grafana, Loki, Tempo
- **Infrastructure:** Docker Compose, Helm, ArgoCD (GitOps)
- **External Services:** Out-of-the-box Supabase integration

---

## 📊 End-to-End Observability

This template is "Observability-First". Every request, database query, and functional effect is instrumented.

### The Stack
- **Traces:** Exported via OTLP to **Tempo**.
- **Metrics:** Collected via **Prometheus**.
- **Logs:** Shipped to **Loki**.
- **Dashboard:** Unified view in **Grafana**.

### How to Run Locally
1. **Start the database:**
   ```bash
   docker-compose up -d
   ```
2. **Start the Observability Stack:**
   ```bash
   docker-compose -f docker-compose.observability.yml up -d
   ```
3. **Run the app:**
   ```bash
   npm run start:dev
   ```
4. **Access Grafana:** Open [http://localhost:3001](http://localhost:3001) (Anonymous Admin enabled).

---

## ☁️ Kubernetes & GitOps

Designed to work on **K3s**, **Kind**, or any standard Kubernetes cluster.

### Deploy with Helm
```bash
helm install rita-v2-baseapp ./charts/rita-v2-baseapp-02
```

### GitOps Workflow (ArgoCD)
A sample ArgoCD application manifest is provided in `gitops/argocd-app.yaml`.
1. Point it to your fork of this repo.
2. Apply it to your cluster: `kubectl apply -f gitops/argocd-app.yaml`.

---

## ⚡ Supabase Integration

We include a pre-configured `SupabaseModule` to jumpstart your integration with Supabase Auth, Database, and Storage.

### Setup
1. Add your credentials to `.env`:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_KEY=your-anon-key
   ```
2. Inject `SupabaseService` into your handlers:
   ```typescript
   constructor(private readonly supabase: SupabaseService) {}

   async doSomething() {
     const client = this.supabase.getClient();
     const { data } = await client.from('mytable').select();
   }
   ```

---

## 🛠 Architecture & Patterns

### Functional Programming (Effect-TS)
This project uses **Effect-TS** to handle side effects and errors.
- **Errors as Data:** We avoid `try/catch` and `throw` where possible.
- **Type Safety:** The compiler ensures you handle all possible error cases.

### Strategic Design (DDD)
The app is organized into **Bounded Contexts** inside `src/modules`. Each module follows Clean Architecture layers:
- `domain`: Pure business logic and entities.
- `usecase`: Application services and orchestration.
- `application`: API controllers, DTOs, and GraphQL resolvers.
- `infrastructure`: Database implementations, external clients.

---

## 📖 Getting Started

1. **Install dependencies:** `npm install`
2. **Setup Env:** `cp .env.dist .env`
3. **Start DB:** `docker-compose up -d`
4. **Generate Schema:** `npm run schema:update`
5. **Run App:** `npm run start:dev`

---

## 📜 License
MIT
