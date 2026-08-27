# Day 77 — Observability Project: Full Stack with Docker Compose

## 1. Full Observability Architecture

The completed observability stack brings together metrics, logs, traces, visualization, and alerting.

### Metrics Pipeline

```text
[Node Exporter] ------> [Prometheus] ------> [Grafana]
[cAdvisor] ------------> [Prometheus] ------> [Grafana]
[OTEL Collector] ------> [Prometheus] ------> [Grafana]
                                             |
                                             v
                                      [Alert Rules]
                                             |
                                             v
                                      [Notifications]
```

### Logs Pipeline

```text
[Docker Containers] --> [Promtail] --> [Loki] --> [Grafana]
```

### Traces Pipeline

```text
[Application / OTLP Client]
             |
             v
      [OTEL Collector]
             |
             v
    [Debug / Jaeger / Tempo]
```

### Complete Data Flow

```text
                         OBSERVABILITY STACK

        ┌─────────────── Metrics ───────────────┐
        │                                        │
[Node Exporter] ─┐                               │
                 ├──> [Prometheus] ──> [Grafana]
[cAdvisor] ──────┤                         │
                 │                         └──> [Alerts]
[OTEL Collector] ┘

        ┌──────────────── Logs ─────────────────┐
        │                                        │
[Docker Containers] ──> [Promtail] ──> [Loki] ─┤
                                                │
        ┌─────────────── Traces ────────────────┤
        │                                        │
[Application / OTLP] ──> [OTEL Collector] ─────┘
                             |
                         [Grafana]
                             |
                             v
                           [User]
```

The key idea is that different telemetry sources are collected by specialized components and brought together through Grafana for investigation and visualization.

---

# 2. Metrics Pipeline Validation

The metrics pipeline consists of Node Exporter, cAdvisor, the OpenTelemetry Collector, and Prometheus.

### Components

- **Node Exporter** provides host-level metrics such as CPU, memory, disk, and network statistics.
- **cAdvisor** provides container-level resource metrics.
- **OTEL Collector** receives OTLP telemetry and exposes metrics for Prometheus.
- **Prometheus** scrapes, stores, and queries the collected metrics.
- **Grafana** visualizes the metrics and uses them for dashboards and alerting.

### Validation

The Prometheus Targets page should show all required scrape jobs as healthy:

- `prometheus` — self-monitoring
- `node-exporter` — host metrics
- `cadvisor` / `docker` — container metrics
- `otel-collector` — OTLP metrics

### Key Observation

The metrics pipeline provides visibility at both infrastructure and application/container levels. This makes it possible to identify system-wide resource problems as well as resource-heavy individual containers.

---

# 3. Logs Pipeline Validation

The logs pipeline consists of Docker containers, Promtail, Loki, and Grafana.

### How It Works

1. Docker containers generate logs.
2. Promtail reads the container log files.
3. Promtail attaches labels and sends the logs to Loki.
4. Loki stores the logs.
5. Grafana queries Loki using LogQL and displays the results.

### Useful LogQL Queries

**All container logs**

```logql
{job="docker"}
```

**Only notes-app logs**

```logql
{container_name="notes-app"}
```

**Errors across all containers**

```logql
{job="docker"} |= "error"
```

**HTTP request logs from the application**

```logql
{container_name="notes-app"} |= "GET"
```

**Log rate by container**

```logql
sum by (container_name) (rate({job="docker"}[5m]))
```

### Key Observation

The logs pipeline complements the metrics pipeline. Metrics can show that an application is behaving abnormally, while logs can provide the actual messages explaining what occurred.

---

# 4. Traces Pipeline Validation

The traces pipeline uses OTLP and the OpenTelemetry Collector.

### How It Works

1. An application or client generates a trace.
2. The trace is sent using OTLP.
3. The OTEL Collector receives the telemetry.
4. The collector processes the telemetry.
5. The trace is exported to a debug destination in the learning setup.

### Example Trace Structure

```text
HTTP Request
     |
     v
GET /api/notes
     |
     v
SELECT notes FROM database
```

This demonstrates a parent-child relationship between spans.

### Important Trace Information

A trace can contain:

- Trace ID
- Span ID
- Parent span ID
- Service name
- Request/route information
- Timing information
- HTTP attributes
- Database attributes

### Key Observation

Distributed tracing helps identify where time is spent inside a request and how operations in different services are connected.

---

# 5. Prometheus, Grafana, Loki, and OTEL Working Together

The completed architecture provides visibility across the three observability pillars:

| Pillar | Main Components | Purpose |
|---|---|---|
| Metrics | Node Exporter, cAdvisor, OTEL Collector, Prometheus | Measure system and application behaviour |
| Logs | Promtail, Loki | Record and investigate events |
| Traces | OTEL Collector | Follow requests across services |
| Visualization | Grafana | Explore and correlate telemetry |
| Alerting | Prometheus / Grafana | Detect problems and notify teams |

This creates a complete workflow:

**Detect → Investigate → Correlate → Respond**

---

# 6. Unified Production Overview Dashboard

The unified dashboard provides a single view of the health of the observability stack.

## Row 1 — System Health

The system health section contains:

- CPU usage
- Memory usage
- Disk usage
- Number of healthy scrape targets

These panels provide a quick view of the underlying host and monitoring infrastructure.

## Row 2 — Container Metrics

The container section contains:

- Container CPU usage
- Container memory usage
- Number of active containers

This makes it easier to identify containers consuming excessive resources.

## Row 3 — Application Logs

The log section contains:

- Application logs
- Error rate
- Log volume by container

This provides direct access to application events without leaving the main dashboard.

## Row 4 — Service Overview

The service section provides additional information such as:

- Prometheus scrape performance
- OTEL telemetry received

### Dashboard Goal

The dashboard is designed to answer the first questions an engineer asks during an incident:

- Is the host healthy?
- Are the containers healthy?
- Are Prometheus targets up?
- Are errors increasing?
- Which container is consuming resources?
- Is telemetry still flowing?

---

# 7. Configuration Comparison

The Day 73–76 configuration was compared with the reference repository.

| Component | My Version | Reference Repository | What to Compare |
|---|---|---|---|
| `prometheus.yml` | Built during Days 73–74 | Root directory | Scrape jobs and intervals |
| `loki-config.yml` | Built on Day 75 | `loki/` | Storage and schema configuration |
| `promtail-config.yml` | Built on Day 75 | `promtail/` | Log discovery and collection |
| `otel-collector-config.yml` | Built on Day 76 | `otel-collector/` | Receivers, processors, and exporters |
| `datasources.yml` | Built on Day 74 | `grafana/provisioning/` | Prometheus and Loki datasources |
| `docker-compose.yml` | Built across Days 73–76 | Root directory | All eight services and networking |

### Reflection

The biggest difference between building the stack day by day and using the reference repository is organization and integration. Building it incrementally helped understand each component independently, while the reference stack demonstrates how those components work together as one system.

---

# 8. What Would Be Added for Production Readiness?

The current stack is suitable for learning and for demonstrating the architecture, but several improvements would be needed for a real production environment.

## Alertmanager

Alertmanager would provide dedicated alert routing, grouping, silencing, and notification management.

It could route alerts to platforms such as:

- Slack
- PagerDuty
- Email

## Grafana Tempo or Jaeger

Instead of sending traces only to debug output, a production deployment should use a trace backend such as Grafana Tempo or Jaeger for persistent storage and trace exploration.

## HTTPS / TLS

Production endpoints should use encryption so telemetry and management interfaces are protected in transit.

## Authentication and Authorization

Grafana, Prometheus, and other exposed services should require appropriate authentication and access controls.

## Log Retention and Storage Limits

Retention policies and storage limits should be configured so that log and metric data does not grow without control.

## High Availability

Critical observability components should use multiple replicas or other high-availability designs to avoid losing monitoring capability when a single instance fails.

## Secrets Management

Passwords, API keys, webhook URLs, and other sensitive values should be managed through a secure secrets-management solution rather than being stored directly in configuration.

## Backup and Recovery

Persistent monitoring data and important Grafana dashboards/configuration should have backup and recovery procedures.

---

# 9. Comparison with Managed Solutions

Managed observability platforms such as Datadog, New Relic, and AWS CloudWatch provide many of the same capabilities without requiring the organization to operate every component itself.

| Self-Managed Stack | Managed Observability Platform |
|---|---|
| Full control over components | Service provider manages infrastructure |
| Highly customizable | Fast to deploy and operate |
| Requires maintenance and upgrades | Less operational maintenance |
| Infrastructure and storage are managed by you | Provider manages underlying infrastructure |
| Can reduce vendor dependency | Usually stronger vendor integration |
| More engineering effort | Lower operational overhead |

### Self-Managed Stack

The Docker Compose stack provides hands-on experience with:

- Prometheus
- Grafana
- Loki
- Promtail
- OpenTelemetry
- Node Exporter
- cAdvisor
- Alerting

This gives deeper understanding of how the observability components work internally.

### Managed Solutions

Managed platforms are useful when the priority is reducing operational effort and getting an observability platform running quickly at scale.

The trade-off is less control over the underlying architecture and potential vendor dependency.

---

# 10. Mapping the Five-Day Observability Block

| Day | What Was Built |
|---|---|
| 73 | Prometheus, PromQL, and metrics fundamentals |
| 74 | Node Exporter, cAdvisor, and Grafana dashboards |
| 75 | Loki, Promtail, LogQL, and log-metric correlation |
| 76 | OTEL Collector, distributed traces, and alerting |
| 77 | Full-stack integration and the unified Production Overview dashboard |

### Learning Progression

The five-day block followed a logical progression:

**Metrics → Infrastructure Metrics → Logs → Traces → Alerting → Full Integration**

Each day added another capability to the previous day's stack until all three observability pillars were connected.

---

# 11. Key Takeaways from the Five-Day Observability Block

## Observability Is More Than Monitoring

Monitoring tells us that a system is unhealthy. Observability gives us the data needed to investigate why it is unhealthy.

## Metrics, Logs, and Traces Complement Each Other

- **Metrics** show what is happening.
- **Logs** explain events and errors.
- **Traces** show where a request spends time or fails.

## Exporters Extend Prometheus

Node Exporter and cAdvisor make infrastructure and container metrics available to Prometheus even when those systems do not expose the required metrics directly.

## Grafana Provides the Investigation Layer

Grafana brings dashboards, metrics, and logs into one interface and makes it easier to correlate different signals.

## OpenTelemetry Provides a Standard Telemetry Pipeline

The OTEL Collector provides a flexible way to receive, process, and export telemetry to different observability backends.

## Alerting Turns Observability into Action

A dashboard requires an engineer to look at it. Alerts allow the system to notify the team when important conditions occur.

## Configuration as Code Improves Reproducibility

Configuration and provisioning files make the observability environment easier to reproduce, version, review, and deploy.

---

# 12. Final Architecture Summary

The completed stack contains eight main services:

| Service | Port | Purpose |
|---|---:|---|
| Prometheus | 9090 | Metrics collection, storage, and querying |
| Node Exporter | 9100 | Host system metrics |
| cAdvisor | 8080 | Container metrics |
| Grafana | 3000 | Visualization and alerting |
| Loki | 3100 | Log storage |
| Promtail | 9080 | Log collection |
| OTEL Collector | 4317 / 4318 / 8889 | Telemetry collection and export |
| Notes App | 8000 | Sample application |

Together, these services form a production-style observability architecture in Docker Compose.

The final result connects:

**Metrics + Logs + Traces + Dashboards + Alerting**

into a single observability workflow.
