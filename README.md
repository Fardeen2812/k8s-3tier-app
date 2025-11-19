
-----

# 🧱 K8s Note App — From Local to Cloud-Native (AWS EKS)

A simple **note-taking web app** built to demonstrate a real-world **DevOps learning journey**. This project has evolved from a single local container to a scalable, 3-tier application running on  **AWS EKS, provisioned via Terraform.**.

It showcases the transition from manual operations to Infrastructure as Code (IaC) and persistent cloud storage.

-----

## 🧩 Project Overview

| Layer | Technology | Purpose |
|-------|-------------|----------|
| **Frontend** | Nginx, HTML/CSS/JS | Serves static UI & acts as a reverse proxy |
| **Backend** | Flask (Python 3.9) | REST API for note operations |
| **Database** | Redis (StatefulSet) | Persistent in-memory data storage |
| **Infrastructure** | Terraform (AWS) | Managed control plane and worker nodes
| **Orchestration** | Kubernetes (Minikube) | VPC, EKS Cluster, ECR Repositories, IAM |

-----

## 📁 Repository Structure

```
k8s-3tier-app/
│
├── frontend/
│   ├── dockerfile          # Nginx Dockerfile (Multi-arch support)
│   ├── nginx.conf          # Nginx reverse proxy config
│   └── index.html          # Static UI
│
├── backend/
│   ├── app.py              # Flask API
│   ├── dockerfile          # Backend Dockerfile (Multi-arch support)
│   └── requirements.txt    # Python dependencies
│
├── k8s/                    # Kubernetes Manifests
│   ├── 1-redis-headless-service.yaml
│   ├── 2-redis-statefulset.yaml
│   ├── 3-backend-deployment.yaml
│   ├── 4-backend-service.yaml
│   ├── 5-frontend-deployment.yaml
│   ├── 6-frontend-service.yaml
│   ├── 7-frontend-hpa.yaml
│   └── 8-backend-hpa.yaml
│
├── terraform-app/          # Main Infrastructure Code
│   ├── main.tf             # EKS, VPC, and ECR definitions
│   ├── backend.tf          # Remote state configuration (S3)
│   ├── variables.tf
│   └── outputs.tf
│
└── terraform-backend/      # One-time setup for S3 State bucket
│   ├──  main.tf
│   ├── variable.tf
```

-----

## 🚀 The DevOps Journey (Completed Milestones)

### Phase 1: Local Development

* Containerized Flask and Redis using Docker.

* Orchestrated locally with **Docker Compose** to solve networking issues.

* Refactored to a **3-Tier Architecture** (Nginx + Flask + Redis) to resolve CORS and API routing issues.

### Phase 2: Local Kubernetes (Minikube)

* Migrated to **Minikube** using raw K8s manifests.

* Implemented **Service Discovery** so Nginx could find the Backend.

* Refactored Redis from a Deployment to a **StatefulSet** with PVCs to solve data persistence issues.

### Phase 3: Cloud Native (AWS EKS & Terraform)

* **Infrastructure as Code:** Provisioned a production-ready VPC, EKS 1.29 Cluster, and ECR repositories using Terraform modules.

* **Remote State:** Configured Terraform to use S3 and DynamoDB for secure, shared state management.

* **Multi-Arch Builds:** Built and pushed `amd64` images to ECR to ensure compatibility with AWS worker nodes.

* **Persistent Cloud Storage:** Enabled the AWS EBS CSI Driver to bind Redis PVCs to real gp2 EBS volumes.

* **Scaling:** Implemented Horizontal Pod Autoscalers (HPA) for frontend and backend service

## ☁️ How to Deploy on AWS EKS

> 📖 See my complete Troubleshooting Log here! Troubleshooting.md <

## 1. Provision Infrastructure

Navigate to the terraform directory and apply the configuration.

```bash
cd terraform-app
terraform init
terraform apply
```

Note the ECR Repository URLs and Cluster Name from the outputs.

## 2. Build & Push Images

Login to ECR and push your images. ***Note:*** If you are on a Mac (M1/M2), you must build for ```linux/amd64.```

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```
```bash
# Build and Push
docker buildx build --platform linux/amd64 -t <BACKEND_REPO_URL>:v1 ./backend --push
docker buildx build --platform linux/amd64 -t <FRONTEND_REPO_URL>:v1 ./frontend --push
```

## 3. Configure kubectl

Update your local kubeconfig to communicate with the new EKS cluster.

```bash
aws eks update-kubeconfig --name 3tier-app-cluster --region us-east-1
```

## 4. Deploy Application

Apply the Kubernetes manifests. Ensure your manifests reference the correct ECR image URLs.

```bash
kubectl apply -f k8s/
```

## 5. Verify Deployment

Check that all pods are running and the LoadBalancer has been provisioned.
```bash
kubectl get all
```

 ![alt text](<Screenshot 2025-11-18 at 4.59.34 PM.png>)



## 6. Access the App

Get the DNS name of the Classic Load Balancer created by AWS.

```bash
kubectl get service frontend-service
```

Copy the ```EXTERNAL-IP``` (e.g., ```a1b2c...elb.amazonaws.com```) and open it in your browser.

![> 📸 \[Add screenshot here of the app running in browser with the AWS ELB URL\] <](<Screenshot 2025-11-13 at 1.32.50 PM.png>)

## 🧭 The Road Ahead

* [ ] CI/CD Pipeline: Automate the build-and-deploy process using GitHub Actions.

* [ ] Monitoring Stack: Deploy Prometheus and Grafana via Helm charts.

* [ ] Ingress Controller: Replace the simple LoadBalancer with an Nginx Ingress Controller for better routing rules.

* [ ] TLS/SSL: Secure the application with HTTPS using AWS ACM or Cert-Manager.

## 👨‍💻 Author

Fardeen Ali
**🚀 DevOps Engineer**
**Building scalable, cloud-native systems one layer at a time.**

## 🪪 License

This project is open source under the MIT License.

🧩 *“Don’t just build an app — build the system that builds and runs the app.”*