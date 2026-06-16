# Day 29 – Introduction to Docker

## 🐳 Task 1: What is Docker?

### What is a container and why do we need them?
A container is a standardized unit of software that packages up code and all its dependencies so the application runs quickly and reliably from one computing environment to another. We need them to solve the classic *"It works on my machine!"* problem. If it runs in a container on my laptop, it will run exactly the same way on a production cloud server.

### Containers vs Virtual Machines (VMs)
* **Virtual Machines:** Virtualize the hardware. Every VM requires a full, heavy Guest Operating System (like Windows or Ubuntu) to run on top of a Hypervisor. They take up gigabytes of storage and take minutes to boot.
* **Containers:** Virtualize the Operating System. They share the host machine's OS kernel and only contain the application and its binaries/libraries. They are incredibly lightweight (often just megabytes) and boot in milliseconds.

### Docker Architecture
Docker uses a Client-Server architecture:
* **Docker Client:** The terminal command line (`docker run`, `docker build`) where we type our commands.
* **Docker Daemon (`dockerd`):** The background service running on the host machine that listens to the client and does the heavy lifting (building, running, and distributing containers).
* **Docker Images:** Read-only templates with instructions for creating a container (like a blueprint).
* **Docker Containers:** The live, running instances of an image.
* **Docker Registry (Docker Hub):** The cloud library where images are stored and downloaded from (public or private).

---

## ⚙️ Task 2: Install Docker

I already had Docker installed on my Ubuntu machine (`sachin-H510M-K-V2`). After verifying my user group permissions, I ran the classic verification command.

**Running `hello-world`:**
```bash
docker run hello-world
```
* **Observation:** Docker checked if I had the `hello-world` image locally. When it couldn't find it, it automatically pulled it from Docker Hub, created a container, printed a success message explaining how Docker works, and then stopped.

---

## 🚀 Task 3: Run Real Containers

**1. Running Nginx (Web Server):**
```bash
docker run -d -p 80:80 nginx
```
* **Observation:** This downloaded the Nginx web server. Using `curl localhost:80`, I was able to see the raw HTML of the "Welcome to nginx!" default webpage proving the container was successfully routing traffic to my machine.

**2. Running Ubuntu in Interactive Mode:**
```bash
docker run -it ubuntu /bin/bash
```
* **Observation:** By using the `-it` (interactive + tty) flags, my terminal prompt completely changed from `sachin@sachin...` to `root@c8a0058b8f2d:/#`. I was literally inside a mini, isolated Ubuntu Linux machine running on top of my actual Ubuntu OS!

**3. Container Management Commands Used:**
* `docker ps`: Listed my running Nginx container.
* `docker ps -a`: Listed all containers, including the stopped `hello-world` and `ubuntu` containers.
* `docker stop <container_id>`: Stopped the running process.
* `docker rm <container_id>`: Deleted the container permanently.

---

## 🔍 Task 4: Explore

I practiced running containers with customized configurations:

**Detached Mode & Naming:**
```bash
docker run -d --name simple-nginx-container -p 80:80 nginx
```
* **What's different?** The `-d` flag runs the container in the background. Instead of locking up my terminal with server logs, Docker just prints the long container ID and gives me my terminal prompt back. The `--name` flag made it much easier to identify than the random names Docker assigns.

**Checking Logs:**
```bash
docker logs <container_id>
```
* **Observation:** Even though the container was running in the background, I could still fetch its historical output and access logs using this command.

**Executing Commands Inside a Running Container:**
```bash
docker exec -it simple-nginx-container bash
```
* **Observation:** Instead of starting a new container, `docker exec` allowed me to "open a door" and step inside the already-running Nginx container to look around its file system.
