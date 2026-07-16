# Day 57: Kubernetes Resource Management and Probes

Running Pods without defined limits or health checks is like driving a car blindfolded without a fuel gauge. Kubernetes assumes everything is fine until the entire cluster crashes. 

This document breaks down the difference between running a cluster blindly versus using Requests, Limits, and Probes to create a self-healing environment.

---

## The Scenario: Without vs. With Controls

### ❌ What Happens If We DON'T Use Them
* **Resource Starvation:** A memory-leaking application consumes all the RAM on a worker node. Essential system processes crash, and other Pods on the same node get evicted.
* **Traffic Blackholes:** An application starts up but takes 30 seconds to connect to the database. Kubernetes sends user traffic to it instantly, resulting in 30 seconds of HTTP 500 errors.
* **Zombie Containers:** A web server deadlocks. The container process is technically still running, so Kubernetes thinks it's healthy, but users just see spinning loading screens. No automatic restart occurs.

### ✅ What Happens If We DO Use Them
* **Smart Placement:** Kubernetes reads the `requests` and places the Pod only on a node that actually has the capacity for it.
* **Containment:** The memory-leaking app hits its `limit` and is instantly isolated and killed (OOMKilled) before it can take down the node.
* **Traffic Control:** A `readinessProbe` blocks traffic from reaching the app until the database connection is fully established. 
* **Self-Healing:** A `livenessProbe` detects the deadlocked web server and automatically restarts the container, restoring service without human intervention.

---

## Requests vs. Limits (Scheduling vs. Enforcement)

Kubernetes manages resources using two distinct concepts:

* **Requests (The Guarantee):** This is for the **Scheduler**. When you set a request (e.g., `cpu: 100m`, `memory: 128Mi`), the scheduler looks for a node with at least that much unallocated capacity. If the cluster is full, the Pod stays in a `Pending` state. 
* **Limits (The Maximum):** This is for the **Kubelet** (the agent running on the node). Limits enforce a hard ceiling at runtime. If an application tries to use more resources than its limit, the Kubelet steps in to stop it.

**Quality of Service (QoS) Classes:**
* **Guaranteed:** Requests and Limits are exactly the same.
* **Burstable:** Requests are lower than Limits.
* **BestEffort:** No Requests or Limits are set (these are the first to be evicted if the node runs out of resources).

---

## What Happens When Limits Are Exceeded?

How Kubernetes reacts depends entirely on the type of resource being abused. 

### Exceeding CPU Limits (Compressible)
CPU is a compressible resource. If a container tries to use more CPU than its limit, Kubernetes **throttles** the container. 
* **Result:** The application slows down, latency increases, but the container is **not** killed.

### Exceeding Memory Limits (Incompressible)
Memory cannot be compressed. If a container tries to allocate more memory than its limit allows, the Linux kernel steps in immediately.
* **Result:** The container is terminated instantly with no warning. 
* **Symptoms:** You will see `Reason: OOMKilled` and `Exit Code: 137` (which is standard exit code 128 + SIGKILL) when you run `kubectl describe pod`.

---

## Liveness vs. Readiness vs. Startup Probes

Probes are how Kubernetes checks the actual health of your application, not just whether the container process is running.

### 1. Startup Probe (The Shield)
* **Purpose:** Gives heavy, slow-starting legacy applications extra time to initialize.
* **Action on Failure:** Kills and restarts the container. 
* **Key Detail:** While a startup probe is running, all liveness and readiness probes are disabled. They only take over once the startup probe succeeds.

### 2. Liveness Probe (The Defibrillator)
* **Purpose:** Detects if an application is stuck, deadlocked, or in a broken state that it cannot recover from.
* **Action on Failure:** Restarts the container.
* **Example:** Checking if a background worker is still processing queue items. If it hangs for 3 minutes, the liveness probe fails, and Kubernetes restarts it.

### 3. Readiness Probe (The Traffic Cop)
* **Purpose:** Detects if an application is ready to accept HTTP traffic.
* **Action on Failure:** Removes the Pod's IP address from the Service endpoints. **It does NOT restart the container.**
* **Example:** An app is doing heavy background processing and cannot handle web requests temporarily. The readiness probe fails, Kubernetes stops sending user traffic, and once the app catches up, the probe passes and traffic resumes.

---
*(Note: Attach your screenshots of the OOMKilled, Pending, and probe events below this section as required by your submission).*
