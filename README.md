
-----

# 🧱 K8s Note App — A DevOps Journey

A simple **note-taking web app** built to demonstrate a real-world **DevOps learning journey**. This project evolves from a single container to a 3-tier, persistent application running on **Kubernetes (Minikube)**.

It showcases the evolution from a simple Docker setup to a cloud-native application, complete with a `StatefulSet` for persistent data storage.

-----

## 🧩 Project Overview

| Layer | Technology | Purpose |
|-------|-------------|----------|
| **Frontend** | Nginx, HTML/CSS/JS | Serves static UI & acts as a reverse proxy |
| **Backend** | Flask (Python 3.9) | REST API for note operations |
| **Database** | Redis (StatefulSet) | Persistent in-memory data storage |
| **Orchestration** | Kubernetes (Minikube) | Container orchestration for all services |
| **Local Dev** | Docker, Docker Compose | (Alternative) for simple local testing |

-----

## 📁 Repository Structure

```
k8s-3tier-app/
│
├── frontend/
│   ├── dockerfile          # Nginx Dockerfile
│   ├── nginx.conf          # Nginx reverse proxy (K8s Service aware)
│   ├── index.html          # Static frontend UI
│   └── static/
│       └── favicon.ico
│
├── backend/
│   ├── app.py              # Flask API (pure backend)
│   ├── dockerfile          # Backend Dockerfile
│   └── requirements.txt    # Python dependencies
│
├── k8s/
│   ├── 1-redis-headless-service.yaml   # Creates stable DNS for Redis pods
│   ├── 2-redis-statefulset.yaml        # Deploys Redis as a stateful app
│   ├── 3-backend-deployment.yaml       # Deploys the Flask API
│   ├── 4-backend-service.yaml          # Internal service for backend
│   ├── 5-frontend-deployment.yaml      # Deploys the Nginx frontend
│   └── 6-frontend-service.yaml         # Exposes the app via NodePort
│
└── docker-compose.yml      # For local Docker-only testing
```

-----

## 🚀 The DevOps Journey (Completed Milestones)

### 1\. Docker Fundamentals

Containerized the Flask backend with a `Dockerfile` and ran it locally.

### 2\. Docker Compose (2-Tier)

Added a `docker-compose.yml` to launch and network the `app` (Flask) and `redis` services.

### 3\. 3-Tier Architecture & Reverse Proxy

Refactored the app into a 3-Tier system to solve CORS/network issues.

  * **Frontend:** Created an **Nginx** service to act as a reverse proxy.
  * **Backend:** Stripped the Flask app into a **pure API**.
  * **Result:** A scalable design accessible from `ngrok`.

### 4\. Kubernetes Deployment (Minikube)

Migrated the entire 3-tier application from Docker Compose to **Kubernetes**.

  * Wrote 6 K8s manifest files (`Deployment`, `Service`) to define the desired state.
  * Deployed all services to a local **Minikube** cluster.
  * Configured Nginx to use K8s **service discovery** (`backend-service`) instead of container names.

### 5\. Persistent Data (StatefulSet)

Refactored the Redis database from a disposable `Deployment` to a **`StatefulSet`**.

  * **Problem:** Using a `Deployment` for Redis with 2 replicas caused inconsistent data (different notes on refresh).
  * **Solution:**
    1.  Created a **Headless Service** for stable network identity.
    2.  Wrote a **`StatefulSet`** manifest for Redis.
    3.  Created a **Persistent Volume Claim (PVC)** to request 1Gi of stable storage.
  * **Result:** The Redis pod (`redis-0`) now survives restarts and crashes with all its data intact. The app is now stateful\!

-----

## 🚀 How to Deploy on Kubernetes (Minikube)

These instructions assume you have [Minikube](https://minikube.sigs.k8s.io/docs/start/) installed.

### 1\. Start Minikube

```bash
minikube start
```

### 2\. Set Docker Environment

Point your terminal to Minikube's internal Docker daemon. This is **critical** so you build images *inside* the cluster.

```bash
# For bash/zsh
eval $(minikube -p minikube docker-env)

# For PowerShell
# minikube -p minikube docker-env | Invoke-Expression
```

### 3\. Build Your App Images

Build the backend and frontend images with the tag K8s expects.

```bash
docker build -t backend-app:v1 ./backend
docker build -t frontend-app:v1 ./frontend
```

### 4\. Apply All K8s Manifests

This one command creates all 6 resources in order.

```bash
kubectl apply -f k8s/
```

### 5\. Check Deployment Status

Wait for all pods to be `Running`. You can also see your new `StatefulSet` (sts) and `PersistentVolumeClaim` (pvc).

```bash
kubectl get all,pvc
```

-----

![alt text](<Screenshot 2025-11-13 at 1.35.13 PM.png>)

### 6\. Open Your Application

This command will automatically open the app in your browser.

```bash
minikube service frontend-service
```

-----

![alt text](<Screenshot 2025-11-13 at 1.32.50 PM.png>)

### 7\. Access from the Internet (Optional)

1.  In the terminal running `minikube service`, note the local port (e.g., `127.0.0.1:61289`).
2.  In a **new terminal**, run `ngrok` on that port:
    ```bash
    ngrok http 61289
    ```

-----

## ⚙️ (Alternative) Run with Docker Compose

For quick, non-Kubernetes testing:

```bash
docker-compose up --build
```

Access the app at `http://localhost:8080`.

-----

## 🧭 The Road Ahead

  * [ ] **Infrastructure as Code (Terraform + AWS):** Provision a real ECR registry and EKS cluster.
  * [ ] **CI/CD Automation (GitHub Actions):** Build a pipeline to auto-build, test, and deploy to EKS on every `git push`.
  * [ ] **Monitoring:** Integrate Prometheus & Grafana for observability.
  * [ ] **Security:** Secure the app with HTTPS Ingress and manage secrets in K8s.

-----

## 👨‍💻 Author

Fardeen Ali
🚀 Devops engineer
Building this project step-by-step to master real-world DevOps —
from Docker and CI/CD pipelines to cloud-native Kubernetes deployments.

## 🪪 License

This project is open source under the MIT License.

🧩 *“Don’t just build an app — build the system that builds and runs the app.”*