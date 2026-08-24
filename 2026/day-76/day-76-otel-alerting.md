# Day 76 — OpenTelemetry and Alerting

## 1. OpenTelemetry Architecture

OpenTelemetry (OTEL) is a vendor-neutral, open-source framework for generating, collecting, and exporting telemetry data such as metrics, logs, and traces.

It is not a backend. Instead, it collects and ships telemetry to backends such as Prometheus, Jaeger, Loki, Datadog, or other supported systems.

### OTEL Collector

The OpenTelemetry Collector is a standalone service that receives, processes, and exports telemetry.

Its pipeline has three main components:

### Receivers

Receivers accept telemetry data from sources.

Examples:
- OTLP over gRPC
- OTLP over HTTP
- Prometheus
- Jaeger

### Processors

Processors transform or prepare telemetry before it is exported.

Examples:
- Batching
- Filtering
- Sampling

### Exporters

Exporters send telemetry to a backend or destination.

Examples:
- Prometheus
- Debug output
- Jaeger

### OTEL Data Flow

```text
Application / Client
        |
        | OTLP
        v
[Receivers]
        |
        v
[Processors]
        |
        v
[Exporters]
        |
        +----> Prometheus
        +----> Debug Output
        +----> Jaeger / Tempo
```

---

## 2. OTLP

OTLP stands for **OpenTelemetry Protocol**.

It is the standard protocol used to send OpenTelemetry telemetry data.

OTLP supports:

- **gRPC** on port `4317`
- **HTTP** on port `4318`

Using OTLP allows applications and telemetry agents to send metrics, logs, and traces to the OpenTelemetry Collector in a standardized format.

---

## 3. Distributed Traces

A distributed trace follows a single request as it travels through multiple services.

Each individual step is called a **span**.

A span can contain:

- Trace ID
- Span ID
- Parent span ID
- Start time
- Duration
- Attributes

### Example

```text
User Request
     |
     v
API Gateway
   Span 1
     |
     v
Auth Service
   Span 2
     |
     v
Database
   Span 3
```

Together, the spans form the complete trace of the request.

Distributed tracing is useful for identifying where a request is slow or where a failure occurs across multiple services.

---

## 4. OTEL Collector Configuration

The collector configuration uses:

- OTLP receivers to accept telemetry.
- A batch processor to group telemetry before export.
- A Prometheus exporter to expose metrics for Prometheus to scrape.
- A debug exporter to print traces and logs to the collector output.

### Metrics Pipeline

```text
OTLP Metrics
     |
     v
  Receiver
     |
     v
Batch Processor
     |
     v
Prometheus Exporter
     |
     v
 Prometheus
```

### Traces Pipeline

```text
OTLP Traces
     |
     v
  Receiver
     |
     v
Batch Processor
     |
     v
 Debug Exporter
     |
     v
Collector Logs
```

For this learning setup, traces and logs are sent to debug output. In a production environment, they could be exported to a dedicated tracing backend such as Jaeger or Grafana Tempo.

---

## 5. Test Trace

A test OTLP trace was sent to the OpenTelemetry Collector.

The trace contained:

- Service name: `my-test-service`
- Span name: `test-span`
- HTTP method: `GET`
- HTTP status code: `200`
- Trace ID and Span ID

The collector received the trace through its OTLP HTTP receiver and printed the span details using the debug exporter.

### Trace Flow

```text
Test Request
     |
     v
OTLP HTTP Receiver
     |
     v
Batch Processor
     |
     v
Debug Exporter
     |
     v
Collector Logs
```

---

## 6. OTLP Metrics Through the Collector

The collector can also receive metrics through OTLP.

The test metric used was:

```text
test_requests_total
```

The metric travelled through this pipeline:

```text
OTLP Metric
     |
     v
OTEL Collector
     |
     v
Prometheus Exporter
     |
     v
Prometheus
```

The metric can then be queried in Prometheus.

### Key Takeaway

The OpenTelemetry Collector acts as a bridge between telemetry producers and different observability backends.

---

## 7. Prometheus Alerting Rules

Prometheus alerting rules define conditions that should trigger an alert.

### `expr`

The PromQL expression that determines whether the alert condition is true.

### `for`

Defines how long the condition must remain true before the alert fires.

This helps prevent alerts from firing because of short-lived spikes.

### `labels`

Adds metadata to the alert, such as:

- `severity: warning`
- `severity: critical`

Labels can be used for routing and grouping notifications.

### `annotations`

Provide human-readable information about the alert, such as a summary and description.

---

## 8. Alerts Configured

### High CPU Usage

Triggers when CPU usage remains above **80%** for more than **2 minutes**.

**Severity:** Warning

**Purpose:** Detect sustained high CPU utilization.

### High Memory Usage

Triggers when memory usage remains above **85%** for more than **2 minutes**.

**Severity:** Warning

**Purpose:** Detect sustained high memory utilization.

### Container Down

Detects when the `notes-app` container disappears from the monitored time series.

**Severity:** Critical

**Purpose:** Detect when the application container is no longer being observed.

### Target Down

Triggers when a Prometheus scrape target has an `up` value of `0` for more than **1 minute**.

**Severity:** Critical

**Purpose:** Detect unreachable monitoring targets.

### High Disk Usage

Triggers when root filesystem usage remains above **90%** for more than **5 minutes**.

**Severity:** Critical

**Purpose:** Detect dangerously low remaining disk space.

---

## 9. Alert States

Prometheus alerts can move through different states:

### Inactive

The alert condition is not currently true.

### Pending

The condition is true, but the configured `for` duration has not yet elapsed.

### Firing

The condition has remained true for the required duration and the alert is active.

### Why the Pending Period Matters

A `for` duration helps prevent alert flapping.

For example, if CPU briefly reaches 85% for a few seconds, an alert configured with `for: 2m` will not immediately fire.

---

## 10. Prometheus Alerts vs Grafana Alerts

### Prometheus Alerts

Prometheus alerts are evaluated by Prometheus using alerting rules written with PromQL.

They are useful when:

- Alerts are based directly on Prometheus metrics.
- Alert conditions are part of the Prometheus monitoring configuration.
- Infrastructure-level monitoring rules are managed alongside Prometheus configuration.

### Grafana Alerts

Grafana can evaluate alert rules and send notifications through configured contact points and notification policies.

They are useful when:

- Alerts need to be managed through Grafana.
- Multiple datasources are involved.
- Notification management is centered around Grafana.
- Alerts need routing through contact points such as email or Slack.

### When Would You Use Each?

Prometheus alerting is a strong choice for metric-based infrastructure rules directly associated with the Prometheus monitoring stack.

Grafana alerting is useful when notification management, routing, and visualization are centered around Grafana.

---

## 11. Grafana Alerting Workflow

### Contact Point

A contact point defines where notifications are sent.

Example:

**DevOps Team**

It can use an integration such as email or Slack.

### Alert Rule

A Grafana alert rule defines:

- The query
- The threshold
- The evaluation interval
- The required duration
- Alert labels
- The contact point

### Notification Policy

A notification policy determines how alerts are routed based on their labels.

For example:

- `severity=warning`
- `severity=critical`

This allows different alert severities to be routed differently.

---

## 12. Full Observability Architecture

The observability stack now covers all three pillars.

### Metrics Pipeline

```text
[Node Exporter] -----> [Prometheus] -----> [Grafana Dashboards]
[cAdvisor] ----------> [Prometheus] -----> [Grafana Dashboards]
[OTEL Collector] ----> [Prometheus] -----> [Grafana Dashboards]
                                      ----> [Alert Rules]
                                                |
                                                v
                                          Notifications
```

### Logs Pipeline

```text
[Docker Containers] -> [Promtail] -> [Loki] -> [Grafana]
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

### Three Pillars

```text
             OBSERVABILITY
                  |
       +----------+----------+
       |          |          |
     Metrics     Logs      Traces
       |          |          |
   Prometheus    Loki       OTEL
       |          |       Collector
       +----------+----------+
                  |
               Grafana
```

---

## 13. Services in the Full Stack

| Service | Port | Purpose |
|---|---:|---|
| Prometheus | 9090 | Metrics storage and querying |
| Node Exporter | 9100 | Host system metrics |
| cAdvisor | 8080 | Container metrics |
| Grafana | 3000 | Visualization and alerting |
| Loki | 3100 | Log storage |
| Promtail | 9080 | Log collection agent |
| OTEL Collector | 4317/4318/8889 | Telemetry collection and export |
| Notes App | 8000 | Sample application |

---

## 14. Key Takeaways

- OpenTelemetry provides a vendor-neutral framework for telemetry collection and export.
- The OTEL Collector is built around receivers, processors, and exporters.
- OTLP is the standard protocol used to transport OpenTelemetry telemetry.
- Distributed traces are made up of spans that represent individual steps in a request.
- The collector can receive OTLP metrics and expose them for Prometheus.
- The collector can receive OTLP traces and send them to debug output or a tracing backend.
- Prometheus alerting rules detect metric conditions and can classify alerts by severity.
- Grafana alerting provides contact points and notification policies for alert delivery.
- The stack now combines metrics, logs, traces, dashboards, and alerting into one observability workflow.
