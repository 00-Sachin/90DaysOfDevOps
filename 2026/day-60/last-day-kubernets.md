# Day 60 Capstone Project: Cloud-Native WordPress & MySQL on Kubernetes

## Executive Summary
This document concludes the 60-day Kubernetes journey by detailing the architecture, testing, reflections, and tool ecosystem behind deploying a self-healing, auto-scaling, stateful web application (WordPress + MySQL) in Kubernetes.

---

## 1. System Architecture

The application is deployed in an isolated namespace (`capstone`) following a microservices pattern that decouples stateful storage from stateless web application layers.
### Resource Connection Breakdown
* **Namespace (`capstone`)**: Logical boundary isolating all project resources.
* **Database Layer (`StatefulSet`)**: Runs a single MySQL 8.0 pod (`mysql-statefulset-0`). It connects to a **1Gi Persistent Volume Claim** (`ReadWriteOnce`) mounted at `/var/lib/mysql` to guarantee data persistence across pod restarts.
* **Database Network Layer (`Service`)**: A headless `ClusterIP` service (`mysql-service`) exposes port `3306`, giving the database a predictable cluster-internal DNS domain (`mysql-service.capstone.svc.cluster.local`).
* **Secrets & Configuration**:
  * **`mysql-secret`**: Stores sensitive credentials (`MYSQL_ROOT_PASSWORD`, `MYSQL_USER`, `MYSQL_PASSWORD`) mounted safely into both MySQL and WordPress.
  * **`wordpress-config`**: Stores non-sensitive variables (`WORDPRESS_DB_HOST`, `WORDPRESS_DB_NAME`).
* **Application Layer (`Deployment`)**: Runs 2 identical WordPress replicas. Probes are configured on `/wp-login.php` for liveness and readiness.
* **Ingress Access (`Service`)**: A `NodePort` service routes external traffic on port `30080` to target port `80` across the WordPress pods.
* **Autoscaling (`HPA`)**: Evaluates CPU utilization across WordPress pods, dynamically scaling between **2 and 10 replicas** when average CPU usage exceeds **50%**.

---

## 2. Self-Healing & Data Persistence Test Results

| Test Scenario | Executed Command | Observed Behavior | Final Result |
| :--- | :--- | :--- | :--- |
| **1. WordPress Pod Deletion (Stateless Self-Healing)** | `kubectl delete pod <wordpress-pod-name> -n capstone` | The WordPress Deployment detected a drop in desired replicas (2 -> 1). Within seconds, a new replacement pod was scheduled, initialized, and passed its readiness probe. Port forwarding / site access remained active via the second replica. | **PASSED** (Zero app downtime) |
| **2. MySQL Pod Deletion (Stateful Self-Healing)** | `kubectl delete pod mysql-statefulset-0 -n capstone` | The StatefulSet controller automatically recreated `mysql-statefulset-0`. The newly spawned pod re-attached to the existing PVC (`mysql-persistent-storage`). | **PASSED** (Identity preserved) |
| **3. Data Persistence Verification** | Refreshed site at `http://localhost:8080` after MySQL recovery | WordPress successfully reconnected to MySQL. The blog post created prior to pod deletion was completely intact. | **PASSED** (Data retained) |

---

## 3. Curriculum Concept Mapping (Days 50–60)

| Kubernetes Concept | Learned Day | Capstone Implementation |
| :--- | :--- | :--- |
| **Architecture & `kubectl`** | **Day 50** | Built the local cluster environment and used `kubectl` commands to inspect and manage cluster health. |
| **Manifests & Pods** | **Day 51** | Structured YAML definition files for individual Pod configurations and container specifications. |
| **Namespaces & Deployments** | **Day 52** | Created `capstone` namespace for workload isolation and used Deployments to maintain stateless WordPress replicas. |
| **Services (ClusterIP & NodePort)** | **Day 53** | Exposed MySQL internally (`ClusterIP`) and WordPress externally (`NodePort` service on port 30080). |
| **ConfigMaps & Secrets** | **Day 54** | Managed non-sensitive variables (`wordpress-config`) and sensitive credentials (`mysql-secret`) independently of container images. |
| **Persistent Volumes (PV/PVC)** | **Day 55** | Created Persistent Volume Claims to allow database files to survive container restarts. |
| **StatefulSets** | **Day 56** | Deployed MySQL as a StatefulSet (`mysql-statefulset-0`) ensuring stable network identity and dedicated storage binding. |
| **Requests, Limits & Probes** | **Day 57** | Configured CPU/Memory limits and added Liveness/Readiness probes targeting `/wp-login.php` on port 80. |
| **Metrics Server & HPA** | **Day 58** | Set up Horizontal Pod Autoscaler (`wordpress-hpa`) to automatically scale WordPress replicas from 2 to 10 based on a 50% CPU threshold. |
| **Helm Package Manager** | **Day 59** | Installed the Bitnami WordPress chart in an isolated `helm-wp` namespace to contrast manual YAML manifests against package management. |
| **End-to-End Capstone** | **Day 60** | Integrated all components into a production-grade, self-healing WordPress + MySQL deployment. |

---

## 4. Retrospective & Reflections

### What Was Hardest?
Debugging the initial database connection handshake. Specifically:
1. **`stringData` vs `data` encoding in Secrets**: Passing pre-base64-encoded strings under `stringData` caused double-encoding, leading to `Access Denied` errors.
2. **DNS Service Naming**: Connecting WordPress to `mysql-0` (the pod) versus `mysql-service` (the service abstraction). Routing via the Service proved far more robust during restarts.

### What Clicked?
The fundamental distinction between **Stateless** and **Stateful** workloads. Seeing a MySQL pod die, get completely replaced by a new container, and seamlessly re-attach to its exact same 1Gi volume—without losing a single blog post—made the power of StatefulSets and PersistentVolumeClaims fully click.

### What I Would Add for Production
If taking this deployment to a live production environment, I would add:
1. **Managed Database / High Availability**: Replace single-node MySQL with a replicated InnoDB Cluster or an external cloud DB (e.g., AWS RDS).
2. **Ingress Controller & TLS**: Deploy NGINX Ingress Controller with `cert-manager` for automatic HTTPS/SSL certificate provisioning instead of NodePort.
3. **Disaster Recovery**: Implement automated volume snapshots using **Velero**.
4. **Observability Stack**: Deploy Prometheus & Grafana to monitor container CPU/RAM metrics and query response times.

---

## 5. The Complete Toolchain Story

To bring this cloud-native application to life, a whole ecosystem of specialized tools worked in unison:

It all began on the local developer machine with **Docker**, containerizing application code and bundling WordPress with **Apache** and **PHP**, alongside **MySQL** database engines. To run these containers in an enterprise-grade environment without provisioning actual cloud servers, **Minikube** (or **Kind**) was spun up to simulate a multi-node Kubernetes cluster locally.

Every infrastructure requirement was translated into structured **YAML** manifest files. Using **`kubectl`**, the primary CLI command-line driver, these manifests were sent to the Kubernetes API server. Kubernetes configured **Secrets** to encrypt sensitive passwords and **ConfigMaps** to inject dynamic application parameters. 

When the **MySQL StatefulSet** was deployed, Kubernetes provisioned a **Persistent Volume Claim (PVC)**, locking MySQL’s data directory to non-volatile storage. To make the database discoverable, a **ClusterIP Service** established an internal DNS endpoint. 

Next, the **WordPress Deployment** spun up redundant application pods. Integrated **Liveness and Readiness Probes** continuously pinged Apache on `/wp-login.php` to guarantee traffic only routed to healthy containers. To handle sudden traffic spikes, the **Metrics Server** fed real-time CPU data into the **Horizontal Pod Autoscaler (HPA)**, empowering the cluster to scale WordPress pods automatically from 2 up to 10. External user access was delivered through a **NodePort Service**, mapping local browser requests straight into the container network.

Finally, to understand enterprise application packaging, **Helm** was introduced. With a single command, Helm auto-generated complex multi-tier charts containing dozens of pre-configured resources, demonstrating how modern DevOps teams streamline deployment pipelines at scale.
