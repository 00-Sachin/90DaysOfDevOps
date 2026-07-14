# Day 51 – Kubernetes Manifests and Your First Pods


## 1. The Anatomy of a Kubernetes Manifest
Every Kubernetes resource is defined using a YAML manifest. Here are the four required top-level fields and what they do:

1.  **`apiVersion`**: Tells Kubernetes which version of its API to use to create the object. For Pods, this is always `v1`. Other resources (like Deployments) use different API groups (like `apps/v1`).
2.  **`kind`**: Specifies the type of Kubernetes resource you are trying to create. For today's tasks, this is `Pod`.
3.  **`metadata`**: Contains data that helps uniquely identify the object. This must include a `name`, and optionally (but highly recommended) includes `labels` for organizing and selecting resources.
4.  **`spec`**: The most important part—it defines the *desired state* for the resource. For a Pod, this specifies which containers to run, the Docker images to use, exposed ports, and commands.

---

## 2. Pod Manifests

Below are the three pod manifests I created today.

### `nginx-pod.yaml`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```
### `busybox-pod.yaml`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-pod
  labels:
    app: busybox
    environment: dev
spec:
  containers:
  - name: busybox
    image: busybox:latest
    command: ["sh", "-c", "echo Hello from BusyBox && sleep 3600"]
```
### `multi-label-pod.yaml`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-label-pod
  labels:
    app: database
    environment: staging
    team: backend
spec:
  containers:
  - name: redis
    image: redis:alpine
```
### 3. Imperative vs. Declarative Approaches
Imperative (kubectl run): You are giving Kubernetes a specific command of how to do something (e.g., kubectl run my-pod --image=nginx). It is fast for quick tests and scaffolding, but it is not easily repeatable, version-controlled, or good for complex setups.

Declarative (kubectl apply -f): You write a YAML manifest describing exactly what you want the final state to look like, and Kubernetes figures out how to make it happen. This is the industry standard (Infrastructure as Code) because the manifests can be tracked in Git, reviewed, and consistently applied across environments.
### 4. What happens when you delete a standalone Pod?
When you delete a standalone Pod, it is permanently destroyed. Because there is no higher-level controller (like a ReplicaSet or Deployment) managing it, Kubernetes will not automatically recreate it. If a node fails or the pod crashes, it is gone. This is why standalone Pods are almost never used in production.
