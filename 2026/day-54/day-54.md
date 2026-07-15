# Managing Dynamic Configurations in Kubernetes: ConfigMaps & Secrets

## Overview
To maintain immutable container images, configuration must be decoupled from the application logic. Kubernetes provides two native primitives for this purpose: **ConfigMaps** and **Secrets**.

---

## 1. ConfigMaps vs. Secrets
Both objects store key-value data to be injected into containers, but their use cases differ based on the sensitivity of the data.

### ConfigMaps
*   **What they are:** Objects used to store non-sensitive configuration data (e.g., application settings, port numbers, log levels, configuration file contents).
*   **When to use:** Use for any data that is not a secret or sensitive credential.

### Secrets
*   **What they are:** Objects designed to store sensitive information (e.g., database passwords, API tokens, TLS certificates).
*   **When to use:** Use for credentials, keys, or any data that requires restricted access via RBAC (Role-Based Access Control).

---

## 2. Injection Methods: Environment Variables vs. Volume Mounts

| Feature | Environment Variables | Volume Mounts |
| :--- | :--- | :--- |
| **Data Format** | Key-Value pairs | Files on a filesystem |
| **Update Behavior** | Requires Pod restart to pick up changes | Can be updated without a Pod restart |
| **Best For** | Single, small configuration values | Large files, complex configurations, certificates |

### Environment Variables
Environment variables are populated at the time the container process starts. They are injected as static strings into the process environment. 

### Volume Mounts
Volume mounts expose the ConfigMap or Secret data as files within a directory in the container. This approach treats the configuration as if it were a physical file existing on the disk, which is ideal for applications that read configuration from files (e.g., `nginx.conf`, `settings.yaml`).

---

## 3. A Note on Security: Base64 Encoding vs. Encryption
A common misconception is that Kubernetes Secrets are "encrypted" because they appear as Base64-encoded strings when viewed in YAML.

*   **Encoding is NOT Encryption:** Base64 is a simple encoding scheme that transforms binary data into ASCII characters. It is **not** a security measure, and it can be trivially decoded by anyone with access to the cluster's API.
*   **True Security:** To protect secrets at rest, you should enable **Encryption at Rest** in your Kubernetes cluster (e.g., using a KMS provider) and strictly enforce RBAC to ensure only authorized users and ServiceAccounts can read Secret objects.

---

## 4. Propagation Behavior
The way Kubernetes updates configuration depends entirely on the injection method chosen:

### Environment Variables (Static)
Environment variables are immutable once the container process has launched. If the underlying ConfigMap or Secret changes, the Pod **will not** see those changes until the Pod is deleted and recreated (restarted).

### Volume Mounts (Dynamic)
When a ConfigMap or Secret is mounted as a volume, Kubernetes periodically synchronizes the data from the API server to the kubelet on the node.
*   **The Propagation:** When you update the object in the cluster, the kubelet eventually updates the files in the mounted directory.
*   **Application Handling:** While the file itself updates automatically, the application **must be designed** to handle this (e.g., by watching the file for changes using `inotify` or by periodically polling the file system for updates) in order to reload the configuration without a restart.
