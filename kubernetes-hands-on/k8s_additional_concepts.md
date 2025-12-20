# Kubernetes Advanced Concepts & Practical Guide

This document complements the Comprehensive Guide by diving deeper into updates, networking logic, resource management, and troubleshooting.

## 1. Updates and Rollbacks

Managing application updates is a critical feature of Kubernetes. The Deployment controller facilitates **Rolling Updates**, ensuring zero downtime by incrementally replacing old Pods with new ones.

### Rolling Update Strategy
In your Deployment YAML, you can control the speed of updates using `maxSurge` and `maxUnavailable`.

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # How many extra pods can be created above the desired count?
      maxUnavailable: 0  # How many pods can be unavailable during the update?
```

- **maxSurge**: Allows starting new pods before killing old ones.
- **maxUnavailable**: Ensures you rarely drop below the desired capacity.

### Managing Rollouts with kubectl

When you change an image (e.g., `nginx:1.14` -> `nginx:1.15`), a release is triggered.

```bash
# 1. Trigger an update
kubectl set image deployment/my-app nginx=nginx:1.15

# 2. Watch the status
kubectl rollout status deployment/my-app

# 3. View rollout history
kubectl rollout history deployment/my-app

# 4. Rollback to the previous version (if something goes wrong)
kubectl rollout undo deployment/my-app

# 5. Rollback to a specific revision
kubectl rollout undo deployment/my-app --to-revision=2
```

---

## 2. Labels, Selectors, and Load Balancing

Labels are the "glue" of Kubernetes. They are key-value pairs attached to objects (like Pods) that allow other objects (like Services) to find them.

### How Services Find Pods
A Service uses a **Selector** to match the **Labels** on Pods. It acts as a load balancer for all Pods that match the selector.

**Pod Definition:**
```yaml
metadata:
  labels:
    app: backend    # <--- Label
    env: prod
```

**Service Definition:**
```yaml
spec:
  selector:
    app: backend    # <--- Selector matches the label above
```

**The Flow:**
1.  Request hits the Service IP.
2.  Service checks its list of Endpoints (updated automatically).
3.  Service forwards traffic to one of the healthy Pods with `app: backend`.

### Node Labels (Scheduling)
You can also label nodes to control where Pods land (Node Affinity).

```bash
# Label a node
kubectl label nodes node-1 disktype=ssd

# Pod specification to require SSD
spec:
  nodeSelector:
    disktype: ssd
```

---

## 3. Advanced Resources & Management

### Namespaces
Namespaces provide isolation (logical clusters).
- **Use cases**: Separating `dev`, `staging`, `prod` or different teams.
- **Context switching**:
  ```bash
  # Change default namespace for all subsequent commands
  kubectl config set-context --current --namespace=dev
  ```

### Logs
- **Multi-container Pods**: If a Pod has a sidecar (e.g., `app` and `log-shipper`), you must specify the container.
  ```bash
  kubectl logs my-pod -c app
  ```
- **Previous Instance**: Useful if a container crashed and restarted.
  ```bash
  kubectl logs my-pod --previous
  ```

### Persistent Volumes (PV) & Claims (PVC)
Storage in Docker is ephemeral (lost when container dies). PV/PVC makes it persistent.

1.  **PersistentVolume (PV)**: The physical storage resource (e.g., AWS EBS, NFS).
2.  **PersistentVolumeClaim (PVC)**: A request for storage by a user.
3.  **Pod Mapping**: The Pod mounts the PVC, not the PV directly.

**Lifecycle**:
`Provision (Create PV)` -> `Bind (PVC finds PV)` -> `Use (Pod mounts PVC)` -> `Reclaim (Delete PVC/PV)`

### Resource Requests & Limits
Crucial for stability.
- **Requests**: What the Pod receives *guaranteed*. Kubernetes schedules based on this.
- **Limits**: The hard cap. If exceeded:
    - **CPU**: Throttled (slowed down).
    - **Memory**: OOMKilled (Process terminated).

```yaml
resources:
  requests:
    cpu: "250m"     # 1/4 core
    memory: "64Mi"
  limits:
    cpu: "500m"     # 1/2 core
    memory: "128Mi"
```

---

## 4. Troubleshooting & Object Inspection

When things break, you need to be a detective.

### The "Describe" Command
This is your first stop for debugging non-running Pods.
```bash
kubectl describe pod <pod-name>
```
**Look for the "Events" section at the bottom.** It will tell you:
- Why scheduling failed (e.g., "Insufficient cpu").
- Why pulling image failed (e.g., "ImagePullBackOff").
- Why health checks failed (e.g., "Liveness probe failed").

### Common Pod States
- **Pending**: Creating... waiting for scheduler or image pull.
- **Running**: At least one container is running.
- **Succeeded**: Finished (for Jobs).
- **Failed**: Crashed with non-zero exit code.
- **CrashLoopBackOff**: Started, crashed, restarted, crashed again... (Check logs!).

### Advanced Inspection
- **Get YAML of running object** (cleaner output):
  ```bash
  kubectl get pod my-pod -o yaml
  ```
- **Filter columns** (e.g., just show Pod IPs):
  ```bash
  kubectl get pods -o wide
  ```
- **Shell into a Pod**:
  ```bash
  kubectl exec -it <pod-name> -- /bin/sh
  ```

---

## 5. RBAC & Security

RBAC (Role-Based Access Control) limits what users or processes can do.

### Core Components
1.  **Subject**: User, Group, or **ServiceAccount** (identity for processes).
2.  **Resource**: Pods, Services, Secrets, etc.
3.  **Verb**: get, list, watch, create, delete.
4.  **Role**: Defines permissions (What can be done?).
5.  **RoleBinding**: Connects a Subject to a Role (Who can do it?).

### ServiceAccount Example
Used by Pods to talk to the API Server.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app-sa
```

### Role & RoleBinding Example (Read-Only)
Allow "reading pods" in the `default` namespace.

```yaml
# 1. The Role (The "What")
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods", "pods/log"]
  verbs: ["get", "watch", "list"]
---
# 2. The Binding (The "Who")
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods-global
  namespace: default
subjects:
- kind: ServiceAccount
  name: my-app-sa
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

*Note: Use `ClusterRole` and `ClusterRoleBinding` for cluster-wide permissions (like reading Nodes).*

---

## 6. Auto-scaling (HPA)

The Horizontal Pod Autoscaler (HPA) automatically adds or removes Pods based on CPU/Memory usage.

### Prerequisites
- **Metrics Server** must be running in the cluster.
- Pods must have **resource requests** defined.

### HPA Manifest

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

### Imperative Command
```bash
# Autoscale deployment 'my-app' to maintain 50% CPU usage
kubectl autoscale deployment my-app --cpu-percent=50 --min=2 --max=10

# Check HPA status
kubectl get hpa
```

---

## 7. Advanced Scheduling

Control exactly where your Pods run.

### Node Affinity
More expressive than `nodeSelector`.
- **Hard rule (Required)**: Pod *must* run on node with label. If no node exists, Pod stays Pending.
- **Soft rule (Preferred)**: Scheduler *tries* to find matching node, but if not, runs anywhere.

```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
```

### Taints and Tolerations
- **Taint**: Applied to a **Node**. Says "keep away unless you have a pass".
- **Toleration**: Applied to a **Pod**. The "pass" to enter a tainted node.

**Example**: Reserve a node for GPU work.
1.  **Taint the node:**
    ```bash
    kubectl taint nodes gpu-node special=true:NoSchedule
    ```
2.  **Add Toleration to Pod:**
    ```yaml
    spec:
      tolerations:
      - key: "special"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
    ```

### Pod Affinity / Anti-Affinity
Schedule Pods based on **labels of other Pods** running on the node.
- **Pod Affinity**: "Run this Pod on the same node as Pods with label `app=db`" (Co-location).
- **Pod Anti-Affinity**: "Do NOT run this Pod on the same node as `app=web`" (High Availability / Spread).

```yaml
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - web
        topologyKey: "kubernetes.io/hostname"
```
