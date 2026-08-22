# Day 75 — Log Management with Loki and Promtail

## 1. Logging Pipeline

The logging pipeline built today is:

```text
Docker Containers
        |
        v
    Promtail
        |
        v
      Loki
        |
        v
     Grafana
        |
        v
       User
```

### How the Pipeline Works

- Docker containers generate log output.
- Promtail reads Docker container log files.
- Promtail adds labels and sends the logs to Loki.
- Loki stores the logs and indexes their labels.
- Grafana connects to Loki and uses LogQL to search and visualize the logs.

---

## 2. Why Does Loki Index Labels Instead of Full Log Text?

Loki does not index the complete contents of every log line. Instead, it indexes the labels attached to log streams and stores the actual log data separately.

### Why This Approach?

Indexing only labels:

- Reduces storage and indexing overhead.
- Makes Loki simpler to operate.
- Can reduce infrastructure cost.
- Fits well with the Prometheus-style label-based model.

### Trade-Off

The main trade-off is search power.

Because Loki does not create a full-text index for every word in every log line:

- It is generally cheaper and simpler than a full-text search system.
- Label-based filtering is efficient.
- Searching arbitrary text across very large log volumes can be less powerful than a full-text search engine such as Elasticsearch.

### Conclusion

Loki is well suited to observability-focused log aggregation where efficient label-based filtering and Grafana integration are important. A full-text search platform such as Elasticsearch is more appropriate when advanced text search and indexing are major requirements.

---

# 3. Loki Configuration

### Important Configuration Concepts

- `auth_enabled: false` enables single-tenant mode for this learning environment.
- `server.http_listen_port` defines the HTTP port used by Loki.
- `store: tsdb` specifies the index storage engine.
- `object_store: filesystem` stores log chunks on the local filesystem.
- `replication_factor: 1` means the setup uses a single Loki instance without replication.

### Storage

Loki uses persistent storage so that collected logs are not lost when the container is recreated.

---

# 4. Promtail Configuration

Promtail is the log collection agent used to read Docker logs and send them to Loki.

### Important Configuration Concepts

- **Positions file:** Tracks which log lines have already been read and shipped.
- **Client:** Defines the Loki endpoint where logs are pushed.
- **Log path:** Identifies the Docker JSON log files Promtail should read.
- **Docker pipeline stage:** Parses Docker's JSON log format and extracts information such as the timestamp, stream, and log message.

### Why the Volume Mounts Matter

- `/var/lib/docker/containers` gives Promtail read access to Docker container log files.
- `/var/run/docker.sock` allows Promtail to discover Docker container metadata such as names and labels.

### Positions File

The positions file works like a bookmark. It allows Promtail to remember where it stopped reading a log file.

If the positions file is deleted, Promtail may read previously collected log lines again.

---

# 5. LogQL Queries

LogQL is Loki's query language. It is used to select log streams, filter log content, search for patterns, and generate metrics from logs.

## Query 1 — All Docker Logs

```logql
{job="docker"}
```

**Purpose:** Returns all logs associated with the Docker job.

**Result:**  
[Write what the query returned.]

---

## Query 2 — Prometheus Container Logs

```logql
{container_name="prometheus"}
```

**Purpose:** Filters logs so that only logs from the Prometheus container are displayed.

**Result:**  
[Write what the query returned.]

---

## Query 3 — Error Logs

```logql
{job="docker"} |= "error"
```

**Purpose:** Finds log lines containing the word `error`.

**Result:**  
[Write what the query returned.]

---

## Query 4 — Exclude Health-Check Noise

```logql
{job="docker"} != "health"
```

**Purpose:** Removes log lines containing `health` from the results.

**Result:**  
[Write what the query returned.]

---

## Query 5 — HTTP 4xx and 5xx Logs

```logql
{job="docker"} |~ "status=[45]\d{2}"
```

**Purpose:** Uses a regular expression to find log lines containing HTTP 4xx or 5xx status codes.

**Result:**  
[Write what the query returned.]

---

# 6. Additional LogQL Queries

## Log Count Over Time

```logql
count_over_time({job="docker"}[5m])
```

Counts the number of log entries over the previous five minutes.

## Log Rate

```logql
rate({job="docker"}[5m])
```

Calculates the rate of log entries per second.

## Top Containers by Log Volume

```logql
topk(5, sum by (container_name) (rate({job="docker"}[5m])))
```

Shows the containers producing the highest log volume.

---

# 7. Exercise — Error Logs from notes-app

### Find Error Logs from notes-app in the Last Hour

```logql
{container_name="notes-app"} |= "error"
```

Use the Grafana time-range selector to set the time window to **Last 1 hour**.

### Count Error Lines Per Minute

```logql
sum(count_over_time({container_name="notes-app"} |= "error"[1m]))
```

This counts matching error log lines over one-minute windows.

> The exact container label name may vary depending on the Promtail configuration and discovered Docker labels. Check the available labels in Grafana Explore if the query returns no data.

---

# 8. Metrics and Logs Together in Grafana

Keeping metrics and logs in the same Grafana environment makes incident response faster because both types of information can be investigated from the same interface.

### Benefits

- No need to switch between separate monitoring systems.
- Metrics can identify when an abnormal event occurred.
- Logs can explain what happened during that event.
- Both can be viewed over the same time range.
- Time synchronization makes it easier to correlate CPU spikes, memory spikes, errors, and application events.

### Example

Suppose the CPU usage of `notes-app` suddenly increases.

1. Prometheus shows the CPU spike.
2. Grafana identifies the exact time of the spike.
3. The Loki panel or Explore view is opened for the same time range.
4. The application logs are inspected.
5. The log messages can reveal the underlying error or event responsible for the spike.

### Why This Helps During Incident Response

Instead of checking a metrics system and a separate logging platform independently, the engineer can correlate the two signals in one place.

This reduces context switching and helps move from:

**"Something is wrong."**

to:

**"This happened at this time, and these log lines help explain why."**

---

# 9. Loki vs ELK Stack

| Loki | ELK Stack |
|---|---|
| Label-based indexing | Full-text indexing |
| Generally simpler to operate | More components and operational complexity |
| Lower indexing overhead in many use cases | More indexing and storage resources |
| Strong integration with Grafana | Strong search and analysis capabilities |
| Good for observability workflows | Good for advanced log search and analytics |

## When Would You Use Loki?

Use Loki when:

- Grafana is already part of the monitoring stack.
- You want centralized log aggregation with relatively simple operations.
- Label-based filtering is sufficient.
- Lower operational complexity is important.
- You want metrics and logs in the same observability platform.

## When Would You Use ELK?

Use ELK when:

- Advanced full-text search is important.
- You need extensive log indexing and analysis.
- You need powerful search capabilities across large and complex log datasets.
- Your organization already operates Elasticsearch, Logstash, and Kibana.

---

# 10. Observability Architecture for Day 75

```text
[Docker Containers]
        |
        | Docker Logs
        v
    [Promtail]
        |
        | Log Streams + Labels
        v
      [Loki]
        |
        | LogQL
        v
     [Grafana]
        |
        +--------------------+
        |                    |
        v                    v
  [Prometheus]           [Loki Logs]
        |
        v
    [Metrics]
```

The result is a single Grafana interface where infrastructure metrics and application logs can be investigated together.

---

# 11. Key Takeaways

- Loki is a log aggregation system designed by the Grafana team.
- Promtail collects Docker logs and ships them to Loki.
- Loki indexes labels rather than the full text of logs.
- LogQL is used to search and analyze Loki logs.
- Metrics and logs together provide stronger incident investigation capabilities.
- Grafana can display Prometheus metrics and Loki logs in the same dashboard.
- Correlating the two helps identify both the symptom and the likely cause of an incident.
