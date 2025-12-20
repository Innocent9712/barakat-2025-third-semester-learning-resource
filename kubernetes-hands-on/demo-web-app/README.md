# Demo Web Application

A simple Nginx-based application to demonstrate:
1.  **Load Balancing**: The index page displays the `HOSTNAME` of the Pod serving the request.
2.  **Persistence**: Nginx logs are saved to a Persistent Volume.

## Deploying to EKS

### 1. Build and Push the Image
Since EKS cannot pull images from your local laptop's Docker daemon, you must push the image to a container registry (like Docker Hub or AWS ECR).

```bash
# 1. Login to Docker Hub (or ECR)
docker login

# 2. Build and Tag (Both latest and specific version)
docker build -t <your-dockerhub-username>/demo-web-app:v1.0.0 -t <your-dockerhub-username>/demo-web-app:latest . --platform linux/amd64

# 3. Push Both Tags
docker push <your-dockerhub-username>/demo-web-app:v1.0.0
docker push <your-dockerhub-username>/demo-web-app:latest
```

**IMPORTANT**: Update `deployment.yaml` to use your pushed image:
```yaml
      - name: demo-web-app
        image: <your-dockerhub-username>/demo-web-app:v1.0.0  # <--- Update this!
        imagePullPolicy: Always
```

### 2. Apply Kubernetes Manifests

```bash
# 1. Create Storage (PV & PVC)
kubectl apply -f pv-pvc.yaml

# 2. Deploy the App
kubectl apply -f deployment.yaml

# 3. Expose via LoadBalancer
kubectl apply -f service.yaml
```

### 3. Verify

**Check Pods:**
```bash
kubectl get pods
```

**Get Load Balancer URL:**
```bash
kubectl get service demo-web-service
```
Copy the `EXTERNAL-IP` (it might look like a long AWS hostname) and open it in your browser. Refresh multiple times to see the **Pod ID** change!

**Check Persistent Logs:**
You should be able to see logs persisting even if Pods restart. Since we used `hostPath` for simplicity, the logs are stored on the *Node's* filesystem at `/tmp/k8s-logs`.

Delete a pod and see the logs are still there.
```bash
kubectl delete pod <pod-name>
```
Check that a new pod has replaced the deleted pod. Get the new pod name and check the logs.
```bash
kubectl get pods
kubectl logs <new-pod-name>

or 

kubectl --kubeconfig ~/.kube/demo-web-app-eks exec -it <new-pod-name> -- tail /var/log/nginx/access.log
```
