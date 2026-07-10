# Day 50 – Kubernetes Architecture and Cluster Setup

## 1. Kubernetes History
Kubernetes was created by Google to solve the immense challenge of managing and scaling thousands of containers simultaneously across clusters of hosts. While Docker alone is fantastic for building and running individual containers, it lacks the built-in capability to orchestrate, auto-scale, and self-heal applications across multiple servers. Inspired by Google's internal container management system called "Borg," Kubernetes was open-sourced to provide a robust orchestration framework. The name "Kubernetes" originates from Greek, meaning "helmsman" or "pilot," which perfectly describes its role in steering containerized applications.

## 2. Kubernetes Architecture Diagram (Text-Based)

**Control Plane (Master Node)** - *The Brain of the Cluster*
*   `API Server`: The front door. All kubectl commands and internal communications go through here.
*   `etcd`: The highly available key-value store database containing all cluster state and configurations.
*   `Scheduler`: The decision-maker that assigns newly created pods to optimal worker nodes based on resources.
*   `Controller Manager`: The loop that constantly watches the cluster to ensure the actual state matches the desired state.

**Worker Node** - *The Muscles of the Cluster*
*   `kubelet`: The agent running on each node that talks to the API server and ensures containers are running in a pod.
*   `kube-proxy`: Maintains network rules and handles routing traffic so pods can communicate.
*   `Container Runtime`: The underlying software (like containerd) that pulls images and runs the containers.

## 3. Tool Chosen: kind (Kubernetes in Docker)
For this setup, I chose **kind**. As seen in my setup process, I created a cluster named `devops-cluster` which provisioned a control plane running node image version v1.36.1. I chose kind because it is lightweight, fast, and uses Docker containers to simulate Kubernetes nodes, making it an excellent and efficient choice for local development and testing. I also have an existing `kind-lc-cluster` configuration with worker nodes running version v1.35.0.

## 4. Screenshots & Verifications
*   **kubectl get nodes**: My `devops-cluster-control-plane` is in a `Ready` status. 
*   **kubectl get pods -n kube-system**: Successfully listed all core components running as pods.

## 5. What Each `kube-system` Pod Does
Looking at the output of `kubectl get pods -n kube-system`, here is what each component is doing:
*   **`kube-apiserver`**: Validates and configures data for the api objects (pods, services, etc.); it's the central management entity.
*   **`etcd`**: The backing store holding the cluster data. If this fails, the cluster loses its memory of what should be running.
*   **`kube-scheduler`**: Watches for new pods without assigned nodes and selects a node for them to run on.
*   **`kube-controller-manager`**: Runs controller processes (like node controller, replication controller) to regulate the state of the system.
*   **`kube-proxy`**: Reflects services defined in the Kubernetes API on each node and can do simple network stream or UDP forwarding across a set of backends.
*   **`coredns`**: Provides DNS services to the cluster, allowing pods to find each other by name rather than IP address.
*   **`kindnet`**: The specific Container Network Interface (CNI) plugin used by kind to handle networking between the nodes.
