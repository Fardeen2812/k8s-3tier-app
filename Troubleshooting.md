
-----

# 🚀 Project Troubleshooting Log

This document logs the real-world problems and solutions encountered during the development of this 3-tier application.

-----

## Docker Compose Issues

### 1\. API 404 & CORS Errors

  * **Symptom:** The app UI would load, but it couldn't fetch or add notes. The browser console showed "API 404" or "CORS" errors.
  * **Analysis:** This happened after the initial 3-tier refactor. The JavaScript in `index.html` was still using a hardcoded API URL (`http://localhost:5001`). When the app was accessed from `http://localhost:8080`, the browser blocked the cross-origin request.
  * **Solution:** Configured Nginx as a reverse proxy. This involved updating `nginx.conf` to forward all requests for `/api/` to the backend service. Then, the `index.html` JavaScript was updated to call a relative path (`/api/notes`), letting Nginx handle the routing.

### 2\. Server 500 Error

  * **Symptom:** The application would respond with a "Server responded with status 500".
  * **Analysis:** This error meant the Flask backend was running but could not successfully connect to the Redis container. The Redis container was likely unhealthy, not running, or not reachable.
  * **Solution:** Used `docker ps` to confirm the `simple_notes_redis` container was in a "healthy" or "running" state. If not, `docker logs simple_notes_redis` was used to find the cause of the error.

### 3\. Connection Error 111

  * **Symptom:** The Flask app crashed with `Error 111 connecting to localhost:6379`.
  * **Analysis:** The Flask container was trying to find Redis on `localhost` (which refers to itself *inside* the container), not on the separate Redis container.
  * **Solution:** Used Docker Compose to place both the Flask and Redis containers on the same internal Docker network. The Flask app's configuration was then updated to connect to Redis using its service name (`REDIS_HOST=redis`).

-----

## Kubernetes Deployment Issues

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