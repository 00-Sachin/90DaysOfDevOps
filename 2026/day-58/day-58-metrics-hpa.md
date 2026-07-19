### Day 58 - Metrics Server and Horizontal Pod Autoscaler (HPA)

**What the Metrics Server is and why HPA needs it**
By default, Kubernetes does not track how much CPU or Memory your pods are actively using; it only knows the resource limits and requests you configured[cite: 9437, 9438]. The Metrics Server is a cluster-wide aggregator of resource usage data. It constantly polls the kubelet on every node (usually every 15 seconds) to ask: *"How much CPU and RAM are your pods actually consuming right now?"* [cite: 9438]

Without the Metrics Server, the Horizontal Pod Autoscaler (HPA) is completely blind[cite: 9455]. HPA relies on real-time metrics to evaluate whether your application is under heavy load or sitting idle[cite: 9456]. If it doesn't have this data, it cannot make scaling decisions.

**How HPA calculates desired replicas**
The HPA controller continually adjusts the number of replicas in a deployment to match the observed metrics against your desired target. It uses the following mathematical formula[cite: 9465]:

`desiredReplicas = ceil[currentReplicas * ( currentMetricValue / desiredMetricValue )]`

**Example Scenario:**
* You have **1** pod running.
* Your target CPU utilization is **50%**.
* Due to heavy load, your pod's CPU usage spikes to **150%**[cite: 9466, 9467].

The calculation will be: `1 * ( 150 / 50 ) = 3` [cite: 9468]
The HPA will automatically scale your deployment up to **3 pods** to balance the load[cite: 9468].

**The difference between autoscaling/v1 and v2**
* **`autoscaling/v1`**: This is the older API version. It only supports scaling based on **CPU utilization**[cite: 9430].
* **`autoscaling/v2`**: This is the modern, advanced API version. It supports scaling based on **CPU, Memory, and custom external metrics**[cite: 9431]. Additionally, it allows you to define fine-grained scaling behaviors, such as controlling exactly how fast the HPA is allowed to scale up or scale down[cite: 9423].
