# Day 53 – Kubernetes Services: Networking and Discovery



## 1. The Problem Services Solve
**The Problem:** In Kubernetes, Pods are ephemeral (short-lived). When a Deployment scales up, scales down, or recreates a Pod after a crash, the new Pods are assigned entirely new IP addresses. If your frontend application is trying to communicate with your backend database, it cannot rely on hardcoded Pod IP addresses because they are constantly changing.

**The Solution:** A **Service** provides a stable, permanent IP address and DNS name that sits in front of a group of Pods. 
* **Deployments** manage the *lifecycle* of the Pods (making sure the right number are running).
* **Services** manage the *network routing* to those Pods. As Pods die and respawn behind the scenes, the Service keeps track of their new IPs automatically, while the frontend only ever has to talk to the unchanging Service IP.

---

## 2. Service Types & Manifests

There are three primary types of Kubernetes Services. Below are the manifests I created for each, along with an explanation of how they differ.

### Type 1: ClusterIP (The Default)
A `ClusterIP` service provides an internal IP address. The service is **only reachable from inside the Kubernetes cluster**. This is perfect for backend databases or internal microservices that the outside world should never access directly.

```yaml
# clusterip-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: dev
spec:
  type: ClusterIP
  selector:
    app: backend-app
  ports:
    - protocol: TCP
      port: 80        # The port the Service listens on
      targetPort: 8080 # The port the actual container is listening on
```
### Type 2: NodePort
A NodePort service opens a specific port (between 30000–32767) on every single Node (server) in the cluster. Any traffic sent to <Node-IP>:<NodePort> is automatically routed to the Service. This is a basic way to expose an app to the outside world.
```
# nodeport-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-nodeport
  namespace: dev
spec:
  type: NodePort
  selector:
    app: frontend-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30080 # External port (optional: K8s will pick one randomly if omitted)
```
### Type 3: LoadBalancer
A LoadBalancer service is the standard way to expose an application in a cloud environment (AWS, GCP, Azure). It automatically provisions an external cloud load balancer, gives you a public IP/URL, and routes that external traffic to your NodePorts/ClusterIPs.
```
# loadbalancer-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: web-loadbalancer
  namespace: dev
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

### 3. How Kubernetes DNS Works for Service Discovery

Kubernetes runs an internal DNS server (usually CoreDNS in the kube-system namespace).

Whenever you create a Service, Kubernetes automatically creates a DNS record for it. Because of this, Pods don't even need to know the Service's IP address—they can just call the Service by its name!

The fully qualified domain name (FQDN) looks like this:

service-name.namespace.svc.cluster.local
#### Example:
If a frontend pod in the dev namespace needs to talk to the backend-service in the same namespace, it can simply make a request to:
http://backend-service

If it needs to talk to a service in a different namespace (e.g., prod), it would use:
http://backend-service.prod.svc.cluster.local

### 4. What are Endpoints?

While a Service provides the stable IP, the Endpoints object is what actually holds the list of the dynamic Pod IP addresses.


When you create a Service with a selector (like app: web-app), Kubernetes continuously scans the cluster for Pods with that exact label. When it finds them, it takes their IPs and adds them to an Endpoints list. When traffic hits the Service, the Service forwards it to one of the IPs in that Endpoints list.


How to inspect Endpoints:

```bash
# View the endpoints for a specific service
kubectl get endpoints backend-service -n dev

# See detailed routing info
kubectl describe service backend-service -n dev
```
If a Service is not working, checking the Endpoints is the first debugging step. If the Endpoints list is empty, it means your Service's selector labels don't match your Pods' labels!

### 5. Verification & Testing
kubectl run test-pod --image=busybox:1.28 -it --rm --restart=Never -- nslookup backend-service
