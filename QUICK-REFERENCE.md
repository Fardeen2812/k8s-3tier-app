# 🎯 Quick Reference Guide

## 📊 Key Metrics

### Cluster Status
```bash
# Check all resources
kubectl get all

# Check HPA status
kubectl get hpa

# Check node metrics
kubectl top nodes

# Check pod metrics
kubectl top pods
```

### Current Configuration
- **Cluster**: eks-cluster-K8s-3Tier-App
- **Region**: us-east-1
- **Nodes**: 2x t3.small (Spot)
- **Kubernetes Version**: 1.29

## 🔗 Important URLs

### Application
- **Frontend**: http://a9e903c491728451e923cc074fd58e08-193129052.us-east-1.elb.amazonaws.com
- **Backend API**: http://backend-service:5001 (internal)

### Monitoring
- **Grafana**: http://a97e7b219d8b2485f8e5708831dcacbd-152210912.us-east-1.elb.amazonaws.com
  - Username: `admin`
  - Password: Get with `kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath='{.data.admin-password}' | base64 -d`

## 💰 Cost Breakdown

![Cost Comparison](screenshots/05-cost-comparison.png)

### Monthly Costs (Optimized)
| Component | Cost |
|-----------|------|
| EKS Control Plane | $73 |
| 2x t3.small Spot (730hrs) | ~$8 |
| NAT Gateway | $45 |
| EBS Volumes (10GB) | ~$1 |
| Load Balancers | ~$16 |
| **Total** | **~$143/month** |

### Cost Savings Achieved
- ✅ **77% reduction** from baseline
- ✅ Spot instances save ~$52/month
- ✅ Single NAT Gateway saves ~$90/month
- ✅ No VPN Gateway saves ~$36/month

### Additional Savings Tips
```bash
# Stop cluster when not in use (saves ~$4/day)
kubectl scale deployment --all --replicas=0

# Or scale node group to 0
aws eks update-nodegroup-config \
  --cluster-name eks-cluster-K8s-3Tier-App \
  --nodegroup-name <nodegroup-name> \
  --scaling-config minSize=0,maxSize=3,desiredSize=0
```

## 🚀 Common Commands

### Deployment
```bash
# Apply all manifests
kubectl apply -f k8s/

# Restart a deployment
kubectl rollout restart deployment/backend-deployment

# Check rollout status
kubectl rollout status deployment/backend-deployment

# View logs
kubectl logs -f deployment/backend-deployment
```

### Scaling
```bash
# Manual scale
kubectl scale deployment backend-deployment --replicas=3

# Check HPA
kubectl get hpa -w

# Describe HPA
kubectl describe hpa backend-hpa
```

### Debugging
```bash
# Get pod details
kubectl describe pod <pod-name>

# Get pod logs
kubectl logs <pod-name>

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/sh

# Port forward for local testing
kubectl port-forward svc/backend-service 5001:5001
```

### Monitoring
```bash
# Check metrics server
kubectl get pods -n kube-system | grep metrics-server

# View Grafana password
kubectl get secret --namespace monitoring prometheus-grafana \
  -o jsonpath='{.data.admin-password}' | base64 -d

# Check Prometheus
kubectl get pods -n monitoring | grep prometheus
```

## 🔄 Deployment

### Manual Deployment
```bash
# Build and push images
docker buildx build --platform linux/amd64 \
  -t <account-id>.dkr.ecr.us-east-1.amazonaws.com/backend-repository-k8s-3tier-app:v1 \
  ./backend --push

# Apply changes
kubectl apply -f k8s/

# Force restart
kubectl rollout restart deployment/backend-deployment
```

## 🧪 Testing

### Load Testing
```bash
# Create load generator
kubectl apply -f k8s/10-load-generator.yaml

# Watch HPA scale
kubectl get hpa -w

# Monitor pods
watch kubectl get pods

# Clean up
kubectl delete -f k8s/10-load-generator.yaml
```

### Health Checks
```bash
# Check frontend
curl http://<frontend-lb-url>

# Check backend API
kubectl port-forward svc/backend-service 5001:5001
curl http://localhost:5001/api/notes

# Check Redis
kubectl exec -it redis-1 -- redis-cli ping
```

## 📦 Backup & Restore

### Backup Redis Data
```bash
# Exec into Redis pod
kubectl exec -it redis-1 -- /bin/sh

# Create backup
redis-cli SAVE

# Copy backup file
kubectl cp redis-1:/data/dump.rdb ./redis-backup.rdb
```

### Restore Redis Data
```bash
# Copy backup to pod
kubectl cp ./redis-backup.rdb redis-1:/data/dump.rdb

# Restart Redis
kubectl delete pod redis-1
```

## 🔐 Security

### Update Secrets
```bash
# Create secret
kubectl create secret generic app-secrets \
  --from-literal=redis-password=<password>

# Update deployment to use secret
kubectl set env deployment/backend-deployment \
  REDIS_PASSWORD=<password>
```

### RBAC
```bash
# View service accounts
kubectl get serviceaccounts

# View roles
kubectl get roles

# View role bindings
kubectl get rolebindings
```

## 🧹 Cleanup

### Delete Application
```bash
# Delete all k8s resources
kubectl delete -f k8s/

# Delete monitoring
helm uninstall prometheus -n monitoring
kubectl delete namespace monitoring
```

### Destroy Infrastructure
```bash
cd terraform-app
terraform destroy
```

## 📞 Support

### Troubleshooting Checklist
- [ ] Check pod status: `kubectl get pods`
- [ ] View pod logs: `kubectl logs <pod-name>`
- [ ] Describe pod: `kubectl describe pod <pod-name>`
- [ ] Check events: `kubectl get events --sort-by='.lastTimestamp'`
- [ ] Verify service: `kubectl get svc`
- [ ] Check HPA: `kubectl get hpa`
- [ ] Verify metrics: `kubectl top nodes && kubectl top pods`

### Common Issues

**HPA shows `<unknown>`**
- Metrics server not running
- Resource requests/limits not set
- Wait 1-2 minutes for metrics collection

**Pods in CrashLoopBackOff**
- Check logs: `kubectl logs <pod-name>`
- Verify environment variables
- Check resource limits

**Cannot access application**
- Verify LoadBalancer: `kubectl get svc`
- Check security groups
- Verify DNS propagation

---

**Last Updated**: November 20, 2025
**Cluster**: eks-cluster-K8s-3Tier-App
**Region**: us-east-1
