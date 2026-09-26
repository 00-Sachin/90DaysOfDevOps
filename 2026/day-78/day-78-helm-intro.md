# Day 78 — Intro to Helm

## Helm Concepts, In My Own Words

**Chart**
A chart is a packaged, versioned bundle of Kubernetes manifests written as templates instead of static YAML. Where I'd normally hand-write `deployment.yml`, `service.yml`, `secrets.yml`, etc., a chart holds the same kind of resources but with placeholders (`{{ .Values.xxx }}`) that get filled in at install time. It's basically "an app, boxed up so it can be installed with one command instead of five files."

**Release**
A release is one running instance of a chart, installed into a cluster with a specific name and a specific set of values. I can install the same `bitnami/mysql` chart twice under two different release names (`bankapp-mysql`, `bankapp-mysql-v2`) and get two independent MySQL deployments. Helm tracks every change to a release as a numbered revision, which is what makes `helm upgrade`, `helm rollback`, and `helm history` possible — kubectl has no equivalent concept.

**Repository**
A repository is just an index of charts, similar to how apt/yum has package repos. `helm repo add bitnami https://charts.bitnami.com/bitnami` points my local Helm client at an index file listing every chart (and every version of every chart) Bitnami publishes, so `helm search` and `helm install bitnami/mysql` know where to fetch from.

**Values**
Values are the configuration inputs a chart's templates read from. Every chart ships a `values.yaml` with sane defaults; I override the specific ones I care about, either inline with `--set key=value` (quick, one-off) or in my own values file (repeatable, version-controllable, and the right choice for anything beyond a couple of overrides).

## Raw YAML vs Helm — Deploying MySQL

| | Raw YAML (`k8s/mysql-deployment.yml` + friends) | Helm (`bitnami/mysql` chart) |
|---|---|---|
| Files to manage | `mysql-deployment.yml`, `secrets.yml`, `pvc.yml`, `pv.yml`, `service.yml` (5 files) | 1 `helm install` command, or 1 values file |
| Secrets | Hand-encoded base64 in a YAML file, committed or handled manually | Generated and managed by the chart |
| Storage | Manually written PV + PVC manifests | One value: `primary.persistence.size` |
| Resource limits | Hardcoded numbers scattered across the Deployment spec | Set via `primary.resources.*` values |
| Metrics/exporter | Not present unless I write it myself | `metrics.enabled=true` |
| Upgrades | `kubectl apply -f` — no history, no diff, no safety net | `helm upgrade`, tracked as a new revision |
| Rollback | Manual — `git revert` and re-apply, or hand-edit the live objects | `helm rollback <release> <revision>` |
| Repeat elsewhere | Copy/paste files, edit values by hand, easy to drift | `helm install` with a different values file — consistent every time |

The short version: raw YAML is fine for a handful of static resources I fully control, but every "knob" (password, storage size, replica count, whether metrics are on) has to be hand-edited in place. Helm turns those knobs into parameters, and gets versioned upgrade/rollback for free.

## `mysql-values.yaml`

```yaml
global:
  security:
    allowInsecureImages: true
image:
  repository: bitnamilegacy/mysql
volumePermissions:
  image:
    repository: bitnamilegacy/os-shell
auth:
  rootPassword: Test@123
  database: bankappdb
primary:
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi
  persistence:
    size: 5Gi
    storageClass: ""
metrics:
  enabled: true
  image:
    repository: bitnamilegacy/mysqld-exporter
  serviceMonitor:
    enabled: false
```

**Field by field:**

- `global.security.allowInsecureImages` — needed because Bitnami moved its free-tier images to the unmaintained `bitnamilegacy` registry (Broadcom's 2025 catalog change); this flag tells the chart to allow pulling images from outside its normal "secure" image list.
- `image.repository` — overrides the MySQL container image to pull from `bitnamilegacy/mysql` instead of the now-broken default `bitnami/mysql` path.
- `volumePermissions.image.repository` — the chart runs a small init container to fix filesystem permissions before MySQL starts; it needs the same legacy-registry override or it fails to pull too.
- `auth.rootPassword` / `auth.database` — the root password and the database that gets auto-created on first boot (`bankappdb`, matching what AI-BankApp expects).
- `primary.resources.requests/limits` — CPU/memory floor and ceiling for the MySQL pod, so it doesn't get starved or allowed to consume the whole node.
- `primary.persistence.size` / `storageClass` — how much disk the PVC requests, and which StorageClass to use (empty string = use the cluster default).
- `metrics.enabled` + `metrics.image.repository` — turns on the `mysqld-exporter` sidecar for Prometheus-style metrics, again pointed at the legacy image repo.
- `metrics.serviceMonitor.enabled` — left off since I don't have the Prometheus Operator CRDs installed in this cluster; would flip to `true` if I did.

## Chart Directory Structure (`bitnami/mysql`, unpacked via `helm pull --untar`)

```
mysql/
  Chart.yaml              # Chart metadata: name, chart version, appVersion, dependencies
  values.yaml             # Every default value the templates can read from
  charts/                 # Any subcharts this chart depends on (bundled dependencies)
  templates/              # The actual Kubernetes manifests, as Go templates
    primary/
      statefulset.yaml    # The StatefulSet that actually runs MySQL
      svc.yaml            # The Service that exposes it inside the cluster
    _helpers.tpl          # Reusable template snippets (naming conventions, labels, etc.)
    NOTES.txt             # Post-install message Helm prints (connection instructions, etc.)
    secrets.yaml          # Secret template — generates the root password Secret
```

- **`Chart.yaml`** — identifies the chart itself. `version` is the chart's own release number (bumps when the templates/structure change); `appVersion` is the version of the actual software inside (MySQL 8.0.x) — the two are independent and often out of sync.
- **`values.yaml`** — the full set of configurable knobs, with defaults. This is what I'm overriding with my `mysql-values.yaml`.
- **`charts/`** — where dependency subcharts would live if this chart bundled others (e.g., a Redis subchart for caching).
- **`templates/`** — where the Helm magic lives: these look like normal Kubernetes YAML but have `{{ .Values.x }}` placeholders that get rendered at install/upgrade time.
- **`_helpers.tpl`** — not a manifest itself, just shared logic (e.g., a standard way of generating resource names) other templates can call into.
- **`NOTES.txt`** — plain text with `{{ }}` templating, printed to the terminal after install — usually has the `kubectl` commands needed to get the password or connect.
- **`secrets.yaml`** — generates the Kubernetes Secret holding the root password, instead of me hand-writing base64 myself.

## Why AI-BankApp's 12 Raw YAML Files Would Benefit From a Helm Chart

Right now those 12 files (deployments, services, secrets, PVCs, configmaps, etc. across the app's components) all have to be kept in sync by hand: any time a value changes — an image tag, a password, a resource limit — I'm hunting across multiple files to update it consistently, and there's nothing stopping the same value from drifting between environments (dev vs staging vs prod) because each is just a separate copy of the YAML.

Packaging them as one Helm chart would mean:

- **One source of truth for config** — all the environment-specific bits (DB password, replica counts, resource sizing, image tags) move into a single `values.yaml`, instead of being scattered and duplicated across 12 files.
- **Environment-specific deploys without file duplication** — `values-dev.yaml`, `values-staging.yaml`, `values-prod.yaml` overlay onto the same chart, instead of maintaining three full copies of every manifest.
- **Real upgrade/rollback history** — right now a bad `kubectl apply` means manually figuring out what changed and reverting it. With a chart, every deploy is a tracked revision I can `helm rollback` in seconds.
- **Dependency management** — if AI-BankApp needs MySQL, Redis, etc., those can be declared as chart dependencies (like the Bitnami MySQL chart's `charts/` folder) instead of me manually deploying and wiring each one up.
- **Easier to share/reuse** — a teammate (or CI/CD) can deploy the whole app with `helm install ai-bankapp ./chart -f values-prod.yaml` instead of needing to know the exact order to `kubectl apply -f` 12 separate files.
- **Templating removes copy-paste bugs** — with 12 static files, a typo in one environment's copy of a Secret or a mismatched label is easy to miss. A single templated source removes that whole category of error.

This is exactly the exercise for tomorrow: turning these 12 raw manifests into `templates/` + one `values.yaml`, the same shape as the Bitnami MySQL chart I just explored.
