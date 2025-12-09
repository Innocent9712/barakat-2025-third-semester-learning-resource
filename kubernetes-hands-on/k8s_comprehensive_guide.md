# Comprehensive Kubernetes Guide

## What is Kubernetes?

Kubernetes, often abbreviated as K8s (K, 8 letters, s), is an open-source container orchestration platform. Think of it as a "manager" or "operating system" for your application containers. Containers, like Docker containers, package an application with all its dependencies (libraries, code, etc.) into a single, isolated unit. While running one or two containers is easy, managing hundreds or thousands across many machines is incredibly complex.

Kubernetes automates the deployment, scaling, and management of these containerized applications. It handles tasks like:

- **Scheduling**: Deciding which machine (node) a container should run on
- **Scaling**: Automatically increasing or decreasing the number of containers based on demand
- **Self-healing**: Restarting containers that fail or replacing unresponsive machines
- **Service Discovery & Load Balancing**: Exposing applications to the outside world and distributing network traffic among containers
- **Storage Management**: Managing persistent storage for applications
- **Configuration Management**: Handling application configuration and secrets securely

The core idea is to describe the desired state of your application—for example, "I want 3 instances of my web server running at all times"—and Kubernetes works continuously to make the actual state match that desired state.

## Kubernetes Architecture

A Kubernetes environment is called a **cluster**. A cluster consists of at least one **Control Plane** and one or more worker machines called **Nodes**.

### The Control Plane: The Brain 🧠

The Control Plane makes global decisions about the cluster (like scheduling) and detects and responds to cluster events. It's the brain of the operation. Its main components are:

- **API Server (kube-apiserver)**: This is the front end of the control plane. It exposes the Kubernetes API. You, and all other parts of the cluster, interact with the cluster through the API server. Think of it as the cluster's receptionist.

- **etcd**: A consistent and highly-available key-value store used as Kubernetes' backing store for all cluster data. It stores the configuration and state of the cluster. It's the cluster's single source of truth.

- **Scheduler (kube-scheduler)**: This component watches for newly created Pods (the smallest deployable units) that have no node assigned and selects a node for them to run on. It's like a logistics manager deciding where to place cargo.

- **Controller Manager (kube-controller-manager)**: This runs controller processes. A controller watches the state of the cluster through the API Server and works to move the current state towards the desired state. Examples include the Node Controller, Replication Controller, and Endpoint Controller.

- **Cloud Controller Manager**: Manages cloud-specific controllers when running in a cloud environment.

### The Node: The Muscle 💪

A Node is a worker machine (it can be a virtual machine or a physical server) where your application containers are actually run. Each node is managed by the Control Plane and contains several key components:

- **Kubelet**: An agent that runs on each node in the cluster. It ensures that containers described in "PodSpecs" are running and healthy. It's the local manager on each worker machine, taking orders from the Control Plane.

- **Kube-proxy**: A network proxy that runs on each node, maintaining network rules. These rules allow network communication to your Pods from network sessions inside or outside of your cluster.

- **Container Runtime**: The software responsible for running containers. Kubernetes supports several container runtimes, with Docker being the most well-known, but others like containerd and CRI-O are also common.

## Key Kubernetes Objects

You interact with Kubernetes by creating, modifying, or deleting objects. These objects represent your application's desired state. Here are the most fundamental ones:

### Pod
The smallest and simplest unit in the Kubernetes object model. A Pod represents a single instance of a running process in your cluster and can contain one or more containers that share storage and network resources.

### Service
An abstract way to expose an application running on a set of Pods as a network service. Since Pods can be created and destroyed, their IP addresses are not stable. A Service gives you a stable endpoint (IP address and DNS name) to access the application, and it automatically load-balances traffic to the correct Pods.

### Deployment
This object describes the desired state for your application. You specify what container image to use and how many replicas (Pods) you want. The Deployment Controller then works to change the actual state to the desired state. It's perfect for stateless applications and handles rolling updates seamlessly.

### ReplicaSet
Its primary purpose is to ensure that a specified number of Pod replicas are running at any given time. A Deployment actually manages ReplicaSets for you, so you typically won't create a ReplicaSet directly.

### ConfigMap & Secret
These objects allow you to decouple configuration and sensitive information (like passwords or API keys) from your container images. This makes your applications more portable and secure. A ConfigMap stores configuration data as key-value pairs, while a Secret does the same for sensitive data, storing it in a more secure way.

### Secret Types

Secrets can be of the following types:

- **Opaque**: General-purpose secrets, such as passwords, API keys, or certificates (most flexible)
- **docker-registry**: Pull images from private registries
- **basic-auth**: Store username/password
- **ssh-auth**: Store SSH private keys
- **tls**: Store TLS certificates and keys
- **service-account-token**: Auto-generated secrets for service accounts
- **bootstrap-token**: Used for cluster bootstrapping with kubeadm

### Additional Important Objects

- **Namespace**: Virtual clusters within a physical cluster, used for resource isolation and organization
- **Ingress**: Manages external access to services, typically HTTP/HTTPS routing
- **PersistentVolume (PV) & PersistentVolumeClaim (PVC)**: Handle storage requirements
- **StatefulSet**: For stateful applications that need stable network identities and persistent storage
- **DaemonSet**: Ensures a copy of a Pod runs on all (or selected) nodes
- **Job & CronJob**: For batch processing and scheduled tasks

## How It Works: The Declarative Model

Kubernetes operates on a **declarative model**. Instead of giving it a sequence of commands to execute (imperative), you provide a configuration file (usually in YAML format) that declares the desired state.

For example, a simple Deployment YAML might say:
- I want an application named my-app
- It should use the nginx:1.14.2 Docker image
- I want 3 replicas of it running

You apply this configuration to the cluster. Kubernetes' controllers then work in a reconciliation loop:

1. Check the current state (e.g., how many replicas of my-app are running?)
2. Compare it to the desired state (3 replicas)
3. If there's a difference, take action to fix it (e.g., if only 2 are running, create one more)

This loop runs continuously, which is why Kubernetes is so resilient and self-healing. If a node goes down and a Pod disappears, the controller notices that the current state (2 replicas) no longer matches the desired state (3 replicas) and immediately schedules a new Pod on a healthy node to compensate.

## Practical Examples: Managing Kubernetes Resources

### 1. Working with Pods

#### Creating a Pod with kubectl (Imperative)
```bash
# Create a simple nginx pod
kubectl run nginx-pod --image=nginx:1.20 --port=80

# Create a pod with resource limits
kubectl run resource-pod --image=nginx:1.20 --requests='cpu=100m,memory=128Mi' --limits='cpu=200m,memory=256Mi'
```

#### Pod Manifest (Declarative)
```yaml
# pod-example.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
    tier: frontend
spec:
  containers:
  - name: nginx-container
    image: nginx:1.20
    ports:
    - containerPort: 80
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
    env:
    - name: ENVIRONMENT
      value: "development"
```

```bash
# Apply the pod manifest
kubectl apply -f pod-example.yaml

# Get pod information
kubectl get pods
kubectl describe pod nginx-pod
kubectl logs nginx-pod
```

### 2. Working with Deployments

#### Creating a Deployment with kubectl
```bash
# Create a deployment
kubectl create deployment web-app --image=nginx:1.20 --replicas=3

# Scale the deployment
kubectl scale deployment web-app --replicas=5

# Update the image (rolling update)
kubectl set image deployment/web-app nginx=nginx:1.21

# Check rollout status
kubectl rollout status deployment/web-app

# Rollback to previous version
kubectl rollout undo deployment/web-app
```

#### Deployment Manifest
```yaml
# deployment-example.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 30
```

```bash
# Apply the deployment
kubectl apply -f deployment-example.yaml

# Monitor the deployment
kubectl get deployments
kubectl get replicasets
kubectl get pods --show-labels
```

### 3. Working with Services

#### Creating Services with kubectl
```bash
# Create a ClusterIP service (internal access only)
kubectl expose deployment web-app --port=80 --target-port=80 --type=ClusterIP

# Create a NodePort service (external access via node IP:port)
kubectl expose deployment web-app --port=80 --target-port=80 --type=NodePort --name=web-app-nodeport

# Create a LoadBalancer service (cloud provider's load balancer)
kubectl expose deployment web-app --port=80 --target-port=80 --type=LoadBalancer --name=web-app-lb
```

#### Service Manifest Examples
```yaml
# service-clusterip.yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
spec:
  type: ClusterIP
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP

---
# service-nodeport.yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-nodeport
spec:
  type: NodePort
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
    protocol: TCP

---
# service-loadbalancer.yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
```

### 4. Working with ConfigMaps and Secrets

#### ConfigMap Examples
```bash
# Create ConfigMap from literal values
kubectl create configmap app-config --from-literal=database_url=postgresql://db:5432/myapp --from-literal=debug=true

# Create ConfigMap from file
echo "app.name=MyWebApp" > app.properties
echo "app.version=1.0.0" >> app.properties
kubectl create configmap app-properties --from-file=app.properties
```

```yaml
# configmap-example.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgresql://db:5432/myapp"
  debug: "true"
  app.properties: |
    app.name=MyWebApp
    app.version=1.0.0
    app.environment=production
```

#### Secret Examples
```bash
# Create Secret from literal values
kubectl create secret generic app-secret --from-literal=db_password=secretpass123 --from-literal=api_key=abc123xyz

# Create Secret from files
echo -n 'admin' > username
echo -n 'secretpassword' > password
kubectl create secret generic user-credentials --from-file=username --from-file=password
```

```yaml
# secret-example.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  db_password: c2VjcmV0cGFzczEyMw==  # base64 encoded 'secretpass123'
  api_key: YWJjMTIzeHl6           # base64 encoded 'abc123xyz'
```

#### Using ConfigMap and Secret in Deployment
```yaml
# deployment-with-config.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-with-config
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app-with-config
  template:
    metadata:
      labels:
        app: web-app-with-config
    spec:
      containers:
      - name: app
        image: nginx:1.20
        env:
        # Environment variables from ConfigMap
        - name: DATABASE_URL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database_url
        - name: DEBUG
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: debug
        # Environment variables from Secret
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: db_password
        volumeMounts:
        # Mount ConfigMap as volume
        - name: config-volume
          mountPath: /etc/config
        # Mount Secret as volume
        - name: secret-volume
          mountPath: /etc/secrets
          readOnly: true
      volumes:
      - name: config-volume
        configMap:
          name: app-config
      - name: secret-volume
        secret:
          secretName: app-secret
```

### 5. Working with Namespaces

```bash
# Create namespace
kubectl create namespace development
kubectl create namespace production

# Set default namespace context
kubectl config set-context --current --namespace=development

# Create resources in specific namespace
kubectl apply -f deployment-example.yaml -n development

# List resources in all namespaces
kubectl get pods --all-namespaces
```

```yaml
# namespace-example.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: development
  labels:
    environment: dev
    team: backend
---
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: prod
    team: backend
```

### 6. Working with Ingress

```yaml
# ingress-example.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-service
            port:
              number: 80
  - host: api.myapp.local
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
```

### 7. Working with Persistent Storage

```yaml
# persistent-volume.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/my-app

---
# persistent-volume-claim.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

```yaml
# deployment-with-storage.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: database-app
  template:
    metadata:
      labels:
        app: database-app
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_PASSWORD
          value: mypassword
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: my-pvc
```

## Essential kubectl Commands

### Basic Operations
```bash
# Get cluster information
kubectl cluster-info
kubectl get nodes
kubectl get namespaces

# Get resources
kubectl get pods
kubectl get deployments
kubectl get services
kubectl get all

# Detailed information
kubectl describe pod <pod-name>
kubectl describe deployment <deployment-name>
kubectl describe service <service-name>

# Logs and debugging
kubectl logs <pod-name>
kubectl logs <pod-name> -c <container-name>  # for multi-container pods
kubectl logs -f <pod-name>  # follow logs
kubectl exec -it <pod-name> -- /bin/bash  # shell into container

# Apply and manage configurations
kubectl apply -f <file.yaml>
kubectl apply -f <directory>/
kubectl delete -f <file.yaml>
kubectl replace -f <file.yaml>

# Resource management
kubectl scale deployment <deployment-name> --replicas=5
kubectl rollout status deployment/<deployment-name>
kubectl rollout history deployment/<deployment-name>
kubectl rollout undo deployment/<deployment-name>

# Port forwarding (for testing)
kubectl port-forward pod/<pod-name> 8080:80
kubectl port-forward service/<service-name> 8080:80
```

### Advanced Operations
```bash
# Resource usage
kubectl top nodes
kubectl top pods

# Editing resources
kubectl edit deployment <deployment-name>
kubectl patch deployment <deployment-name> -p '{"spec":{"replicas":3}}'

# Labels and selectors
kubectl get pods -l app=web-app
kubectl label pod <pod-name> environment=production

# Context and configuration
kubectl config get-contexts
kubectl config use-context <context-name>
kubectl config set-context --current --namespace=<namespace>

# Troubleshooting
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl describe node <node-name>
kubectl cordon <node-name>  # mark node unschedulable
kubectl drain <node-name>   # gracefully evict pods from node
```

## Best Practices for Students

### 1. Resource Management
- Always set resource requests and limits for containers
- Use namespaces to organize and isolate resources
- Implement health checks (readiness and liveness probes)

### 2. Security
- Never store secrets in plain text in YAML files
- Use RBAC (Role-Based Access Control) to limit permissions
- Keep container images updated and scan for vulnerabilities

### 3. Configuration Management
- Use ConfigMaps for non-sensitive configuration
- Use Secrets for sensitive data
- Keep configuration separate from application code

### 4. Monitoring and Observability
- Implement proper logging in applications
- Use labels consistently for resource organization
- Monitor resource usage and set up alerts

### 5. Development Workflow
- Use version control for Kubernetes manifests
- Test configurations in development environments first
- Implement CI/CD pipelines for automated deployments

## Common Troubleshooting Scenarios

### Pod Not Starting
```bash
# Check pod status and events
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# Common issues:
# - Image pull errors (wrong image name/tag)
# - Resource constraints (insufficient CPU/memory)
# - Configuration errors (missing ConfigMap/Secret)
```

### Service Not Accessible
```bash
# Check service and endpoints
kubectl get services
kubectl get endpoints
kubectl describe service <service-name>

# Test connectivity
kubectl run test-pod --image=busybox -it --rm -- /bin/sh
# Inside the pod: wget -qO- http://<service-name>:80
```

### Deployment Issues
```bash
# Check deployment status
kubectl get deployments
kubectl describe deployment <deployment-name>
kubectl rollout status deployment/<deployment-name>

# Check replica sets and pods
kubectl get replicasets
kubectl get pods -l app=<app-label>
```


## Demo Application Overview

This demo application consists of a FastAPI backend and a Vite + React frontend. It uses PostgreSQL for data storage and Redis for caching.

### Backend (FastAPI + Python)
- **FastAPI**: High-performance web framework for building APIs with Python 3.7+
- **SQLAlchemy**: ORM for database interactions
- **Databases**: Async database support
- **Redis**: Caching layer for improved performance 
- **Pydantic**: Data validation and settings management
- **Uvicorn**: ASGI server for running FastAPI applications 

### Frontend (Vite + React + TypeScript)
- **Vite**: Next-generation frontend tooling for fast development
- **React**: UI library for building user interfaces
- **TypeScript**: Typed superset of JavaScript for better developer experience
- **TanStack Router**: Type-safe routing solution for React
- **TanStack Query**: Data fetching and state management
- **Tailwind CSS**: Utility-first CSS framework for styling

### Deployment
- **Docker**: Containerization for easy deployment and scaling
- **Kubernetes**: Orchestration for managing containerized applications

#### Deployment Steps
1. Build Docker images for backend and frontend
```bash
# Backend
docker build \
  -t demo-backend:latest \
  -t demo-backend:k8 \
  ./backend

# Frontend
docker build \
  -t demo-frontend:latest \
  -t demo-frontend:k8 \
  --build-arg VITE_API_BASE_URL=http://localhost:30081 \
  ./frontend
```

2. Apply Kubernetes manifests
```bash
kubectl apply -f demo-app-kubernetes.yml
```
3. Access the application
- Frontend: `http://localhost:30080`
- Backend API: `http://localhost:30081` 


## Extra Learning Resources
- [Kubernetes Official Documentation](https://kubernetes.io/docs/home/)
- [Kubernetes Explained](https://youtu.be/aSrqRSk43lY?si=ej75Fk6secOah6vU)
- [Kubernestes Crash Course](https://youtu.be/s_o8dwzRlu4?si=qehVliChH7oSy9W5)
- [Kubernetes vs Docker](https://youtu.be/2vMEQ5zs1ko?si=WmJv9sy4cstZOvI4)
- [Kind](https://kind.sigs.k8s.io/)
- [Lens IDE](https://k8slens.dev/)
