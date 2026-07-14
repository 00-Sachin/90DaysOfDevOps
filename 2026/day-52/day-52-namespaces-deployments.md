## 📝 Key Concepts Documentation

1. **What namespaces are and why you would use them:**
   Namespaces are virtual clusters backed by the same physical cluster hardware. They are used to isolate resources, divide cluster resources between multiple users/teams, and separate environments (like `dev`, `staging`, and `prod`) so that names don't conflict and accidental deletions are contained.

2. **The Deployment Manifest Explained:**
   * `apiVersion: apps/v1` & `kind: Deployment`: Specifies we are using the Deployment API to manage applications.
   * `replicas: 3`: The Deployment Controller will ensure exactly 3 pods exist at all times.
   * `selector.matchLabels`: Tells the Deployment *how* to find the Pods it is supposed to manage.
   * `template`: The actual blueprint for the Pods. The `labels` in the template must match the `matchLabels` in the selector.

3. **Standalone Pod vs. Deployment-Managed Pod:**
   If a standalone pod is deleted or crashes, it is gone forever. If a Deployment-managed pod crashes or is deleted, the Deployment's underlying ReplicaSet notices the count dropped below the desired state and instantly spins up a replacement.

4. **Scaling Imperatively vs. Declaratively:**
   * **Imperative:** Running `kubectl scale deployment <name> --replicas=N`. Fast and easy, but not version-controlled.
   * **Declarative:** Editing the `replicas` field in the `.yaml` file and running `kubectl apply -f`. Preferred in production because the infrastructure code matches the cluster state.

5. **Rolling Updates and Rollbacks:**
   A rolling update replaces old pods with new ones gradually (e.g., spinning up one new pod, ensuring it is healthy, then terminating one old pod) to ensure zero downtime. If the new version fails, a rollback (`kubectl rollout undo`) quickly reverts the Deployment to its previous stable state using stored ReplicaSet history.

---
