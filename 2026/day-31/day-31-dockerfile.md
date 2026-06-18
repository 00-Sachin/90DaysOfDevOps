# Day 31 – Dockerfile: Build Your Own Images



## 🏗️ Task 1: Your First Dockerfile

I created a directory called `my-first-image` and wrote my very first Dockerfile:

```dockerfile
# Use ubuntu as the base image
FROM ubuntu

# Install curl
RUN apt-get update && apt-get install -y curl

# Set a default command to print a message
CMD ["echo", "Hello from my custom image!"]
```

I then built and tagged the image using `docker build -t my-ubuntu:v1 .` and ran it using `docker run my-ubuntu:v1`. It successfully printed my custom message to the terminal!

---

## 📝 Task 2: Dockerfile Instructions

I created a more complex Dockerfile to understand the core instructions used in production environments:

```dockerfile
# Base image
FROM ubuntu:latest

# Set the working directory inside the container
WORKDIR /app

# Execute a command during the build phase
RUN apt-get update && apt-get install -y iputils-ping

# Copy files from my local machine to the container's /app directory
COPY . /app

# Document the port the application will use
EXPOSE 8080

# The default command to run when the container starts
CMD ["echo", "This is my advanced Dockerfile!"]
```

**Observation:** I learned that `RUN` executes while the image is being built (creating layers), while `CMD` executes only when the container finally starts.

---

## ⚔️ Task 3: CMD vs ENTRYPOINT

I tested the difference between `CMD` and `ENTRYPOINT` by creating two different images.

* **Testing CMD:**
  When I ran a container with `CMD ["echo", "hello"]`, it printed "hello". However, if I ran `docker run <image> hostname`, it completely ignored my `echo` command and ran `hostname` instead. `CMD` is easily overridden.
* **Testing ENTRYPOINT:**
  When I ran a container with `ENTRYPOINT ["echo"]` and passed an extra argument like `docker run <image> sachin`, it appended the argument, printing "echo sachin".

**When to use which?**
* Use `CMD` when you want to provide a default command that users can easily override (like giving them a default bash shell).
* Use `ENTRYPOINT` when you want your container to behave like a specific executable, where any extra arguments passed during `docker run` are fed directly into that executable.

---

## 🌐 Task 4: Build a Simple Web App Image

I created a custom `index.html` file and built a Dockerfile to serve it using an Nginx web server.

**Dockerfile:**
```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
```

I built the image (`docker build -t my-website:v1 .`) and ran it mapped to port 8080 (`docker run -d -p 8080:80 my-website:v1`).

**Result:** When I accessed `localhost:8080` in my browser, my custom HTML page ("Hello form custom web-page by sachin") was successfully served!

---

## 🚫 Task 5: .dockerignore

I created a `.dockerignore` file containing the following:

```plaintext
node_modules
.git
*.md
.env
```

**Observation:** When I ran `docker build`, Docker completely ignored these files and did not send them to the build daemon. This prevents sensitive `.env` files from leaking into the image and speeds up the build process by excluding massive folders like `node_modules`.

---

## ⚡ Task 6: Build Optimization

**Why does layer order matter for build speed?**
Docker caches each line of a Dockerfile as a separate layer. If a layer changes (like editing the source code in a `COPY` command), Docker has to rebuild that layer AND every single layer below it.

Therefore, you should always put instructions that rarely change (like `FROM`, `RUN apt-get install`) at the top, and instructions that change constantly (like `COPY . .` for your source code) at the very bottom. This maximizes Docker's cache usage and makes rebuilding lightning fast!
