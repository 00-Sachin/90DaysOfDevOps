# Day 55 – Kubernetes Persistent Volumes (PV) and Persistent Volume Claims (PVC)
## Why Containers Need Persistent Storage
One of the golden rules of containers is that they are ephemeral. When a Pod crashes or is deleted, its local file system goes down with it. Everything inside is wiped out. This is a serious problem for databases, stateful applications, or anything that needs data to survive a restart. Kubernetes solves this by decoupling the lifecycle of your data from the lifecycle of your Pods using persistent storage.

## What PVs and PVCs Are and How They Relate
To manage storage, Kubernetes uses two main resources:
* **Persistent Volume (PV):** A PV is a cluster-wide resource representing a physical piece of storage that has been provisioned for use by Pods. It acts as an abstraction layer over the actual underlying storage (like a local disk, AWS EBS, or NFS).
* **Persistent Volume Claim (PVC):** A PVC is a namespaced request for storage by a user. 

**How they relate:** Instead of a Pod directly interacting with the underlying storage, the Pod uses a PVC. Kubernetes matches the PVC to an available PV that meets the requested specifications (like capacity and access modes) and binds them together. 

## Static vs Dynamic Provisioning
* **Static Provisioning:** The cluster administrator manually creates the `PersistentVolume` (PV) objects ahead of time, defining the exact storage details. A developer then creates a PVC, which binds to one of these pre-created PVs.
* **Dynamic Provisioning:** Eliminates the overhead of manual creation. Developers simply create a PVC specifying a `StorageClass`. The `StorageClass` automatically provisions the underlying storage and creates the PV on demand the moment it is requested (or when the first consumer Pod is scheduled).

## Access Modes and Reclaim Policies

### Access Modes
Access modes dictate how a volume can be mounted by nodes:
* **ReadWriteOnce (RWO):** The volume can be mounted as read-write by a single node at a time.
* **ReadOnlyMany (ROX):** The volume can be mounted read-only by many nodes simultaneously.
* **ReadWriteMany (RWX):** The volume can be mounted read-write by many nodes simultaneously.

### Reclaim Policies
Reclaim policies dictate what happens to the PV when its associated PVC is deleted:
* **Retain:** The PV is not automatically deleted. The data persists, allowing for manual recovery. Often used for manually created (static) PVs.
* **Delete:** The underlying storage is automatically destroyed along with the PV. This is typically the default for dynamically provisioned volumes.

---

## Troubleshooting Journey: Issues Faced & Resolved
During our hands-on tasks, we ran into several real-world scenarios and blockers that required deep-dive troubleshooting. Here is a log of the issues faced and how we solved them:

### 1. PVC Stuck in `Pending` (WaitForFirstConsumer)
* **Issue:** After creating a PVC, its status remained `Pending` with the event message: *"waiting for first consumer to be created before binding"*.
* **Resolution:** This was expected behavior. The cluster's default StorageClass was set to `volumeBindingMode: WaitForFirstConsumer`. The solution was to deploy a Pod that referenced the PVC, prompting the Kubernetes scheduler to nominate a node and trigger the volume binding process.

### 2. StorageClass Mismatch in Static Provisioning
* **Issue:** A statically created PV and a new PVC were not binding, despite matching capacity and access modes. The PVC stayed in `Pending`.
* **Resolution:** Kubernetes automatically assigned the default `standard` StorageClass to the PVC, while the manual PV had no StorageClass. We resolved this by explicitly defining `storageClassName: ""` in the PVC manifest, forcing it to look for a PV with no StorageClass.

### 3. Dynamic Provisioner CrashLoopBackOff
* **Issue:** During dynamic provisioning, the PVC threw an `ExternalProvisioning` error. Investigating the `local-path-provisioner` Pod in the `local-path-storage` namespace showed it was crashing continuously.
* **Resolution:** Checking the pod logs revealed it was failing due to cluster networking issues.

### 4. Kubernetes API Connection Refused in `kind`
* **Issue:** The provisioner logs showed: `dial tcp 10.96.0.1:443: connect: connection refused`. Because we were using `kind` (Kubernetes IN Docker), the internal Docker network bridge had hung, preventing Pods from communicating with the Kubernetes Control Plane.
* **Resolution:** We opted to delete and recreate the `kind` cluster to flush out the corrupted IP tables and Docker network state.

### 5. Inotify Watch Limit Exhausted (`Too many open files`)
* **Issue:** While trying to recreate the `kind` cluster, it failed to start with a host OS error: `Failed to allocate directory watch: Too many open files`.
* **Resolution:** Linux's `inotify` limits were too low for Docker and Kubernetes. We fixed this by increasing the max user watches and instances directly on the host machine:
