# Observability Documentation — Node Exporter, cAdvisor, and Grafana

## 1. Node Exporter vs cAdvisor

### What is Node Exporter?

Node Exporter is a Prometheus exporter used to expose hardware and operating-system-level metrics from a host machine.

It provides metrics such as:
- CPU usage
- Memory usage
- Disk space and disk I/O
- Network traffic
- Filesystem usage
- System load

### What is cAdvisor?

cAdvisor (Container Advisor) collects resource and performance information about running containers.

It provides metrics such as:
- Container CPU usage
- Container memory usage
- Container filesystem usage
- Container network traffic
- Container resource limits and usage

### Difference

| Node Exporter | cAdvisor |
|---|---|
| Monitors the host machine | Monitors containers |
| Provides OS and hardware metrics | Provides container resource metrics |
| CPU, RAM, disk, network, filesystem | Container CPU, RAM, disk, network |
| Useful for server-level monitoring | Useful for Docker/container-level monitoring |

### When Would You Use Each?

Use **Node Exporter** when you want to understand the health and resource usage of the underlying server or VM.

Use **cAdvisor** when you want to understand how individual containers are consuming resources.

Both can be used together:

**Server → Node Exporter → Prometheus**

**Docker Containers → cAdvisor → Prometheus**

---

# 2. Why Provision Grafana Datasources Using YAML?

Grafana datasources can be configured manually through the UI, but provisioning them through YAML is generally better for DevOps and production environments.

### Advantages

#### Infrastructure as Code
Datasource configuration becomes part of the project files instead of existing only inside Grafana.

#### Repeatability
The same configuration can be deployed consistently across development, testing, staging, and production.

#### Version Control
The YAML file can be stored in Git, allowing changes to be reviewed, tracked, and rolled back.

#### Automation
Grafana can automatically create the required datasource when the environment starts.

#### Reduced Manual Configuration
YAML provisioning avoids repetitive and error-prone UI configuration.

#### Disaster Recovery
If Grafana needs to be recreated, the datasource can be restored automatically from the provisioning file.

### Why This Is Better for DevOps

YAML provisioning follows the **Configuration as Code / Infrastructure as Code** approach. It makes the environment easier to automate, reproduce, and maintain.

---

# 3. PromQL Queries for CPU, Memory, Disk, and Container Metrics

## CPU

### Host CPU Usage

```promql
100 * (1 - avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])))
```

Shows the approximate CPU usage percentage for each host.

### CPU Usage by Mode

```promql
rate(node_cpu_seconds_total[5m])
```

Shows the rate of CPU time spent in different CPU modes.

---

## Memory

### Memory Usage Percentage

```promql
100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))
```

Calculates the percentage of memory currently in use.

### Available Memory

```promql
node_memory_MemAvailable_bytes
```

Shows the amount of memory available on the host.

---

## Disk

### Disk Usage Percentage

```promql
100 * (1 - (node_filesystem_avail_bytes{fstype!~"tmpfs|overlay"} / node_filesystem_size_bytes{fstype!~"tmpfs|overlay"}))
```

Shows an estimate of filesystem usage.

### Available Disk Space

```promql
node_filesystem_avail_bytes
```

Shows available filesystem space.

### Disk Read Rate

```promql
rate(node_disk_read_bytes_total[5m])
```

Shows the disk read rate.

### Disk Write Rate

```promql
rate(node_disk_written_bytes_total[5m])
```

Shows the disk write rate.

---

## Container Metrics

### Container CPU Usage

```promql
rate(container_cpu_usage_seconds_total{container!=""}[5m])
```

Shows the CPU usage rate of running containers.

### Container Memory Usage

```promql
container_memory_usage_bytes{container!=""}
```

Shows current container memory usage.

### Container Network Receive Rate

```promql
rate(container_network_receive_bytes_total{container!=""}[5m])
```

Shows the rate at which containers receive network traffic.

### Container Network Transmit Rate

```promql
rate(container_network_transmit_bytes_total{container!=""}[5m])
```

Shows the rate at which containers transmit network traffic.

### Container Filesystem Usage

```promql
container_fs_usage_bytes{container!=""}
```

Shows filesystem usage for containers.

> Metric names and labels can vary depending on the cAdvisor and container-runtime setup. If a query returns no results, inspect the available metrics and labels in Prometheus.

---

# 4. How Datasource Provisioning Works via YAML

Grafana supports provisioning datasources from configuration files.

The basic flow is:

**YAML Configuration → Grafana Startup → Datasource Creation → Grafana Dashboard Queries**

## Step 1: Create the Provisioning Configuration

Grafana commonly reads datasource provisioning files from:

```text
/etc/grafana/provisioning/datasources/
```

## Step 2: Define the Datasource

The YAML file describes information such as:

- Datasource name
- Datasource type
- Prometheus URL
- Whether it should be the default datasource

Example:

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
```

## Step 3: Mount the Provisioning File

When Grafana runs inside Docker, the provisioning directory can be mounted into the Grafana container so Grafana can read the YAML configuration.

## Step 4: Grafana Reads the Configuration

When Grafana starts, it reads the provisioning files and creates or updates the configured datasource.

This removes the need to manually configure the datasource through the UI.

## Step 5: Dashboards Use the Datasource

Once the datasource is available, Grafana dashboards can query Prometheus using PromQL.

The overall flow is:

```text
Node Exporter ──┐
                ├──> Prometheus ──> Grafana
cAdvisor ───────┘                    │
                                     └──> PromQL Queries
```

---

# 5. Key Takeaways

- **Node Exporter** monitors the host/server.
- **cAdvisor** monitors containers.
- Using both provides infrastructure-level and container-level visibility.
- YAML datasource provisioning follows the **Infrastructure as Code** approach.
- Provisioning makes Grafana configuration reproducible, version-controlled, and easier to automate.
- PromQL can be used to monitor CPU, memory, disk, network, and container resources.
- Grafana reads datasource provisioning files and automatically configures the specified datasources.
