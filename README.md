# 🧱 K8s Note App — DevOps Journey (Flask + Redis + Docker + K8s)

A simple **note-taking web app** built to demonstrate a real-world **DevOps learning journey** — from a single Docker container to a fully automated Kubernetes deployment.

The project evolves week-by-week as new DevOps concepts and tools are added, making it a perfect portfolio piece to showcase practical skills across the DevOps toolchain.

---

## 🧩 Project Overview

| Layer | Technology | Purpose |
|-------|-------------|----------|
| **Frontend** | HTML, CSS (Bootstrap) | Minimal UI for note creation |
| **Backend** | Flask (Python 3.9) | REST API and web server |
| **Cache / DB** | Redis | In-memory data storage for notes |
| **Containerization** | Docker, Docker Compose | Local development & multi-container setup |
| **Infrastructure (Future)** | Terraform + aws | Automated provisioning |
| **Orchestration (Future)** | Kubernetes (AKS) | Cloud-native deployment |
| **CI/CD (Future)** | Jenkins / GitHub Actions | Continuous build, test & deploy |

---

## 📁 Repository Structure



3tier-app/
│
├── backend/
│ ├── app.py # Flask app (API + frontend routes)
│ ├── dockerfile # Backend Dockerfile
│ ├── requirements.txt # Python dependencies
│ ├── templates/ # HTML templates
│ ├── static/ # CSS / JS assets
│ └── dump.rdb # Redis snapshot (optional)
│
└── docker-compose.yml # Multi-container setup (Flask + Redis)


---

# 🗓️ DevOps Roadmap (By Stage)

## 🧩 Week 1 — Docker Fundamentals
🎯 **Goal:** Containerize the Flask backend.

- Created a Dockerfile using Python 3.9-slim as the base.
- Installed dependencies from `requirements.txt`.
- Exposed port `5001` for external access.
- Verified local container runs Flask app successfully.

```bash
docker build -t simple-notes-app .
docker run -p 5001:5001 simple-notes-app


✅ Result: Flask app container runs locally on http://localhost:5001.

⚙️ Week 2 — Docker Compose (Multi-Container Setup)

🎯 Goal: Connect Flask backend with Redis via Docker Compose.

Added docker-compose.yml for multi-container setup.

Defined services:

app → Flask backend

redis → Redis cache

Linked via an internal Docker network.

Passed REDIS_HOST=redis environment variable.

docker-compose up --build


✅ Result: App and Redis containers run together and share data seamlessly.

🌐 Week 3 — External Access via Ngrok

🎯 Goal: Access the app securely from the internet.

Installed and configured ngrok.

Used ngrok to expose local container port.

Tested app on external devices using public HTTPS endpoint.

ngrok http 5001


✅ Result: Flask app accessible via secure URL (e.g., https://xyz.ngrok-free.dev).

☁️ Week 4 — Infrastructure as Code (Terraform + aws) (Upcoming)

🎯 Goal: Provision aws infrastructure using Terraform.

Planned setup:

Amazon Elastic Container Registry (ECR)

Amazon Kubernetes Service (EKS)

Terraform-managed deployments

🧰 Tools: Terraform, aws CLI, ACR

🌀 Week 5 — Kubernetes Deployment (Upcoming)

🎯 Goal: Deploy Flask + Redis stack on AKS.

Write manifests for:

Flask Deployment & Service

Redis Deployment & Service

Configure Secrets, ConfigMaps, and Ingress for external access.

🧰 Tools: kubectl, Helm, AKS

🤖 Week 6 — CI/CD Automation (Upcoming)

🎯 Goal: Automate builds and deployments.

Setup GitHub Actions or Jenkins pipeline:

Trigger on push

Build Docker image

Run tests

Push to ACR

Deploy to AKS automatically

🧰 Tools: Jenkins, GitHub Actions, Terraform, kubectl

📊 Week 7 — Monitoring & Observability (Upcoming)

🎯 Goal: Add metrics and monitoring.

Integrate Prometheus and Grafana.

Set up health checks, dashboards, and alerts.

⚙️ Local Setup
1. Prerequisites

Docker Desktop (Mac / Windows / Linux)

Docker Compose

Python 3.9+ (optional)

ngrok
 (optional for remote access)

2. Clone the Repository
git clone https://github.com/<your-username>/<repo-name>.git
cd 3tier-app

3. Build and Run Containers
docker-compose up --build


Once running, visit:
👉 http://localhost:5001

4. Environment Variables
Variable	Default	Description
REDIS_HOST	redis	Redis hostname (service name in Docker)
REDIS_PORT	6379	Redis port
FLASK_ENV	development	Flask environment

Example manual run:

docker run -p 5001:5001 -e REDIS_HOST=redis simple-notes-app

5. Access From Internet (Optional)
ngrok http 5001


Copy the HTTPS forwarding URL that appears and open it on your phone or another device.

🧰 Common Issues & Fixes
Issue	Cause	Fix
Error 111 connecting to localhost:6379	Redis not reachable from Flask container	Use Docker Compose so both run on same network (REDIS_HOST=redis)
“Server responded with status 500”	Flask app couldn’t reach Redis	Check that redis service is healthy (docker ps, docker logs redis)
Can’t access via phone	Trying to open localhost or firewall blocking	Use ngrok or your machine’s LAN IP (192.168.x.x:5001)
path not found during build	Wrong build context in docker-compose.yml	Ensure context: . if compose file is inside /backend
🧭 Road Ahead

 Deploy on Kubernetes (AKS)

 Integrate Terraform for IaC

 Implement CI/CD (GitHub Actions / Jenkins)

 Add monitoring with Prometheus + Grafana

 Secure with HTTPS ingress & secrets

👨‍💻 Author

Fardeen Ali
🚀 Devops engineer 
Building this project step-by-step to master real-world DevOps —
from Docker and CI/CD pipelines to cloud-native Kubernetes deployments.

🪪 License

This project is open source under the MIT License
.

🧩 “Don’t just build an app — build the system that builds and runs the app.”