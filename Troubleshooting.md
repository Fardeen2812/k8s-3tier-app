
-----

# 🚀 Project Troubleshooting Log

This document serves as a knowledge base of the technical challenges encountered and resolved during the evolution of this project from a local script to a cloud-native EKS deployment.
-----


###  ☁️ Phase 3: AWS EKS & Terraform Issues

  ###   1. Terraform ECR Name Validation

**Issue:** Terraform ``terraform apply`` failed when creating ECR repositories.

**Cause:** I attempted to use CamelCase names like ``Frontend-Repo``, but AWS ECR repository names must satisfy a strict regex (lowercase, numbers, hyphens, underscores only).

**Fix:** Renamed resources in ``main.tf`` to fully lowercase (e.g., frontend-app).


  ###  2. Docker Exec Format Error (CrashLoopBackOff)

**Issue:** Pods deployed to EKS immediately crashed with ```exec /usr/local/bin/python: exec format error```.

**Cause:**  I built the Docker images on my Apple Silicon (M1/M2) Mac, which defaults to ```arm64``` architecture. The AWS EKS worker nodes were running standard x86_64 (amd64) processors.

**Fix:** Rebuilt and pushed the images using docker buildx to force the target architecture:

``docker buildx build --platform linux/amd64 ...``

### 3. Docker Push "Repository Does Not Exist"

**Issue:** Docker failed to push images to ECR.

**Cause:**  I tagged the image with a nested path (e.g., .../my-project/backend), but Terraform had only created top-level repositories.

**Fix:** Retagged the images to match the exact repository URI provided by the Terraform output.

### 4. kubectl Connection Refused / Timeout

**Issue:**  kubectl commands timed out or failed to connect to the cluster API server.

**Cause:** One issue were identified:

          **1.** The AWS CLI was configured with a typo in the region (us-eat-1). 

          **2.** The EKS cluster endpoint was initially private, preventing my local machine from reaching it.

**Fix:** Corrected the region configuration and ensured the EKS cluster endpoint access was set to Public (or properly configured VPN access). Updated kubeconfig via ``aws eks update-kubeconfig``.

### 5. Backend CrashLoop (Redis Unreachable)

**Issue:** The backend pods kept restarting (``CrashLoopBackOff``) even after fixing the architecture issue.

**Cause:** The backend requires a connection to Redis to start. The Redis StatefulSet was stuck in a ``Pending`` state because the Persistent Volume Claim (PVC) could not be bound.

**Fix:** See "PVC Binding Failure" below. Once Redis was fixed, the backend stabilized automatically.

## 6. PVC Binding Failure (Pending Storage)

**Issue:** The Redis PVC remained in ``Pending`` status.

**Cause:**  The EKS cluster (version 1.29) does not include the AWS EBS CSI Driver by default. Without this driver, Kubernetes cannot talk to the AWS EBS API to provision volume storage.

**Fix:** Installed the ``aws-ebs-csi-driver`` add-on to the EKS cluster. The PVC immediately bound to a new gp2 volume, and Redis started successfully.

-----

## ☸️ Phase 2: Kubernetes (Minikube) Issues

### 1\. Nginx 404 Error on Minikube

  * **Symptom:** After deploying to Kubernetes, the app loaded but showed a "Server responded with status 404." This was a *different* 404 error than the one in Docker Compose.
  * **Analysis:** `kubectl get all` showed all pods were `Running`. The issue was traced to the `frontend/nginx.conf`, which had a trailing slash (`/`) on the `proxy_pass` directive: `proxy_pass http://backend-service:5001/;`. This slash was stripping the `/api/` prefix, causing Nginx to request just `/` from the backend.
  * **Solution:** Removed the trailing slash (`proxy_pass http://backend-service:5001;`). This modification ensured the full path (`/api/notes`) was correctly proxied to the Flask service. The frontend image was rebuilt (`docker build ...`) and the pod was redeployed.

### 2\. Inconsistent Data (The "Data Lottery")

  * **Symptom:** With the `redis-deployment` set to `replicas: 2`, refreshing the app showed different notes. New notes would disappear, then reappear on a later refresh.
  * **Analysis:** A Kubernetes `Deployment` creates identical, independent pods. The `redis-service` was load balancing requests between two separate Redis databases. This meant some notes were saved to `redis-pod-A` and others to `redis-pod-B`.
  * **Solution:** Refactored the database to be **stateful**.
    1.  Replaced the `Deployment` with a **`StatefulSet`**.
    2.  Replaced the `ClusterIP` Service with a **Headless Service** (`clusterIP: None`) to give the pod a stable DNS name.
    3.  Added a **`volumeClaimTemplates`** to the `StatefulSet` to automatically create a Persistent Volume (PV).
    4.  Updated the backend's `REDIS_HOST` environment variable to point to the stable DNS name: `redis-0.redis-headless`.
  * **Result:** The app now has a single, persistent Redis pod (`redis-0`) that re-attaches to its storage even if it crashes, ensuring 100% data consistency.

### 3\. Pods Crashing (CrashLoopBackOff & ErrImagePull)

  * **Symptom:** `kubectl get all` showed pods were stuck in `ErrImagePull` or `CrashLoopBackOff`.
  * **Analysis:** The `ErrImagePull` on the `redis` pod meant Minikube's VM couldn't connect to the internet to download the `redis:7` image. The `CrashLoopBackOff` on the `backend` pod was a *symptom* of this; the Flask app was crashing because it couldn't connect to the non-existent Redis service.
  * **Solution:**
    1.  Ran `minikube stop` and `minikube start` to reset the Minikube VM's network connection.
    2.  Ran `kubectl delete -f k8s/` to clean up all broken resources.
    3.  Re-ran `eval $(minikube -p minikube docker-env)` to connect to the VM's Docker daemon.
    4.  Re-applied the manifests with `kubectl apply -f k8s/`.

### 4\. VS Code Schema Errors

  * **Symptom:** VS Code showed a `!` icon or errors like "Matches multiple schemas" on all Kubernetes YAML files.
  * **Analysis:** Multiple extensions (Red Hat YAML, Microsoft Kubernetes, Microsoft Docker) were all trying to validate the same files, creating a conflict. In other cases, network issues blocked the extension from downloading the schema file.
  * **Solution:**
    1.  Uninstalled conflicting extensions.
    2.  Installed the official **Microsoft Kubernetes** extension.
    3.  Created a local `.vscode/settings.json` file in the project to override all other settings and force VS Code to use its local, built-in `kubernetes` schema.
    <!-- end list -->
    ```json
    {
        "yaml.schemas": {
            "kubernetes": ["k8s/**/*.yaml"]
        }
    }
    ```

## 🐳 Phase 1: Docker Compose Issues

  * **Symptom:** The app UI would load, but it couldn't fetch or add notes. The browser console showed "API 404" or "CORS" errors.
  * **Analysis:** This happened after the initial 3-tier refactor. The JavaScript in `index.html` was still using a hardcoded API URL (`http://localhost:5001`). When the app was accessed from `http://localhost:8080`, the browser blocked the cross-origin request.
  * **Solution:** Configured Nginx as a reverse proxy. This involved updating `nginx.conf` to forward all requests for `/api/` to the backend service. Then, the `index.html` JavaScript was updated to call a relative path (`/api/notes`), letting Nginx handle the routing.

###  Server 500 Error

  * **Symptom:** The application would respond with a "Server responded with status 500".
  * **Analysis:** This error meant the Flask backend was running but could not successfully connect to the Redis container. The Redis container was likely unhealthy, not running, or not reachable.
  * **Solution:** Used `docker ps` to confirm the `simple_notes_redis` container was in a "healthy" or "running" state. If not, `docker logs simple_notes_redis` was used to find the cause of the error.

###  Connection Error 111

  * **Symptom:** The Flask app crashed with `Error 111 connecting to localhost:6379`.
  * **Analysis:** The Flask container was trying to find Redis on `localhost` (which refers to itself *inside* the container), not on the separate Redis container.
  * **Solution:** Used Docker Compose to place both the Flask and Redis containers on the same internal Docker network. The Flask app's configuration was then updated to connect to Redis using its service name (`REDIS_HOST=redis`).
