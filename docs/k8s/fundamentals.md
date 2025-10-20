# Kubernetes Fundamentals

Kubernetes is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications.

## Core Components

### Control Plane

- **API Server**: The front-end for the Kubernetes control plane
- **etcd**: Consistent and highly-available key value store
- **Scheduler**: Assigns pods to nodes
- **Controller Manager**: Runs controller processes

### Node Components

- **kubelet**: Agent that runs on each node
- **kube-proxy**: Network proxy
- **Container Runtime**: Software responsible for running containers

## Basic Objects

### Pod

The smallest deployable unit in Kubernetes.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
```

### Service

An abstract way to expose an application running on a set of Pods.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
```

### Deployment

Provides declarative updates for Pods and ReplicaSets.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
```

## kubectl Commands

Essential commands for interacting with Kubernetes:

```bash
# Get cluster info
kubectl cluster-info

# List resources
kubectl get pods
kubectl get services
kubectl get deployments

# Describe resources
kubectl describe pod <pod-name>

# Apply configurations
kubectl apply -f deployment.yaml

# Delete resources
kubectl delete pod <pod-name>
```