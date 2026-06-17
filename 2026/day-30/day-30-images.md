# Day 30 – Docker Images & Container Lifecycle



## 📦 Task 1: Docker Images

I started by pulling three distinct images from Docker Hub: `nginx`, `ubuntu`, and `alpine`.

**Image Size Comparison:**
* `nginx`: ~188MB
* `ubuntu`: ~78.1MB
* `alpine`: ~7.8MB

**Why is Alpine so much smaller than Ubuntu?**
Alpine Linux is built specifically to be a minimal, resource-efficient OS for containers. It strips out all the unnecessary utilities, GUIs, and heavy standard libraries (using `musl libc` and `busybox` instead), whereas the `ubuntu` image includes more standard tools out-of-the-box. For DevOps, Alpine is often the go-to for keeping images lightweight and fast to deploy!

I also successfully practiced inspecting images with `docker inspect ubuntu` (which dumped a massive JSON file of its metadata) and removed an image using `docker rmi ubuntu`.

---

## 🥞 Task 2: Image Layers

I ran `docker image history nginx` to see how the image was built.

**What are layers and why does Docker use them?**
When looking at the history, I saw several lines. Each line represents a "layer" (a step from the Dockerfile used to build the image).

* **Why layers?** Docker layers are read-only and stack on top of each other. Docker uses them for caching. If I build two different apps that both use the base `ubuntu` image, Docker only downloads the `ubuntu` layer once and shares it between both containers, saving massive amounts of disk space and download time.
* **Why 0B?** Some layers show `0 Bytes` because they only change configuration or metadata (like `ENV`, `CMD`, or `EXPOSE` instructions) rather than actually adding files to the system.

---

## 🔄 Task 3: Container Lifecycle

I practiced walking a single container through its entire lifecycle and verifying its state with `docker ps -a` at every step:

* **Create:** `docker create --name test-container nginx` *(State: Created)*
* **Start:** `docker start test-container` *(State: Up)*
* **Pause:** `docker pause test-container` *(State: Up / Paused)*
* **Unpause:** `docker unpause test-container` *(State: Up)*
* **Stop:** `docker stop test-container` *(State: Exited)*
* **Restart:** `docker restart test-container` *(State: Up)*
* **Kill:** `docker kill test-container` *(State: Exited - abnormally)*
* **Remove:** `docker rm test-container` *(Container deleted)*

---

## 💻 Task 4: Working with Running Containers

I spun up an Nginx container in detached mode (`docker run -d --name my-nginx nginx`) and interacted with it:

* **Real-time Logs:** Used `docker logs -f my-nginx` to watch the server access logs live.
* **Exec into the container:** Ran `docker exec -it my-nginx bash` to drop into the shell and explore the internal filesystem.
* **Execute a single command:** Ran `docker exec my-nginx ls -l` to list files without keeping the shell open.
* **Inspect IP:** Used `docker inspect my-nginx | grep IPAddress` to quickly find the internal Docker network IP assigned to my web server.

---

## 🧹 Task 5: Cleanup

To wrap up the day, I learned some powerful cleanup commands to reclaim disk space:

* **Stop ALL running containers:** `docker stop $(docker ps -q)`
* **Remove ALL stopped containers:** `docker rm $(docker ps -aq)`
* **Check Disk Space:** `docker system df` *(Shows exactly how much space images, containers, and volumes are eating up)*.
* **The Nuclear Option:** `docker system prune -a` *(Cleans up all unused containers, networks, and images)*.
