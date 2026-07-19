# Day 59 - Helm: The Kubernetes Package Manager

## What is Helm?
When you build an application in Kubernetes, you usually have to write many different YAML files (like Deployments, Services, and ConfigMaps). Managing all of these separately can get very confusing. 

Helm solves this problem. It acts as a package manager for Kubernetes, similar to how `apt` works for Ubuntu or `brew` works for Mac. It groups all your YAML files together into one easy-to-manage package.

### The Three Core Concepts
To use Helm, you just need to understand these three basic terms:
1. **Chart:** This is the package itself. It contains all the template files needed to run your application.
2. **Release:** This is a running instance of a chart. Every time you install a chart into your cluster, Helm creates a new release.
3. **Repository:** This is an online collection where people store and share charts (like an app store for Kubernetes).

---

## Managing Your Applications with Helm

### 1. Install
To install a chart and create a release, you simply use the install command. This replaces the need to run `kubectl apply` on dozens of files.
```bash
helm install my-app bitnami/nginx
```

### 2. Customize
You do not have to accept the default settings. You can change things like the number of pods by passing custom values using `--set`.
```bash
helm install my-app bitnami/nginx --set replicaCount=3
```

### 3. Upgrade
If you need to make changes to an application that is already running, you can upgrade it without taking it offline.
```bash
helm upgrade my-app bitnami/nginx --set replicaCount=5
```

### 4. Rollback
If an upgrade breaks your application, Helm keeps a history of your changes. You can easily go back to a previous, working version.
```bash
helm rollback my-app 1
```

---

## The Structure of a Helm Chart
When you create your own chart using `helm create my-chart`, it builds a specific folder structure for you:

* **`Chart.yaml`:** This file contains basic information about the chart, like its name and version.
* **`values.yaml`:** This is the default configuration file. It holds the standard settings for your app.
* **`templates/`:** This folder holds all your Kubernetes YAML files (Deployments, Services, etc.).

### How Go Templating Works
Inside the `templates/` folder, the YAML files do not have hardcoded values. Instead, they use **Go Templating** to pull data from your `values.yaml` file. 

For example, instead of writing `replicas: 3` directly in your Deployment file, you write:
```yaml
replicas: {{ .Values.replicaCount }}
```
When Helm installs the chart, it looks at `values.yaml`, finds the number for `replicaCount`, and automatically fills it in for you.

---

## My custom-values.yaml
To customize an installation without writing long commands, you can pass a custom file. Here is my `custom-values.yaml` file:

```yaml
# custom-values.yaml

# This tells Helm to run 3 pods instead of the default 1
replicaCount: 3

service:
  # This changes the service type to NodePort so we can access it from outside the cluster
  type: NodePort
  port: 80

resources:
  # This sets limits so the pods do not consume too much power
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

**How to use it:**
Instead of using `--set`, you just tell Helm to read this file during installation:
```bash
helm install custom-nginx bitnami/nginx -f custom-values.yaml
```
