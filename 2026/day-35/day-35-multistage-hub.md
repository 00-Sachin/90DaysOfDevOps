# Day 35 – Multi-Stage Builds & Docker Hub

## 🐘 Task 1: The Problem with Large Images

To demonstrate the problem, I wrote a simple "Hello World" application in Go (`main.go`).
I wrote a standard, single-stage Dockerfile:

**`Dockerfile` (Single-stage build)**
```dockerfile
FROM golang:1.20
WORKDIR /app
COPY . .
RUN go build -o myapp main.go
CMD ["./myapp"]
```

I built the image (`docker build -t go-app-single .`) and checked its size using `docker images`.

* **Resulting Image Size:** ~800 MB!
* **The Problem:** 800 MB for a "Hello World" app is massive. The reason it is so large is because it includes the entire Go compiler, the OS utilities, and all the build tools needed to compile the code, none of which are actually needed just to run the compiled binary.

---

## 🪶 Task 2: Multi-Stage Build

I rewrote the Dockerfile to use a multi-stage build process.

**`Dockerfile` (Multi-stage build)**
```dockerfile
# Stage 1: Build the app (The "Builder" environment)
FROM golang:1.20 AS builder
WORKDIR /app
COPY . .
# Compile a statically linked binary
RUN CGO_ENABLED=0 GOOS=linux go build -o myapp main.go

# Stage 2: Run the app (The minimal production environment)
FROM alpine:latest
WORKDIR /root/
# Copy ONLY the compiled binary from Stage 1
COPY --from=builder /app/myapp .
CMD ["./myapp"]
```

I built this new image (`docker build -t go-app-multi .`).

* **Resulting Image Size:** ~13 MB!

**Why is the multi-stage image so much smaller?**
In Stage 1, Docker uses the heavy `golang` image (800MB) to compile the code into a binary file. In Stage 2, Docker starts fresh with a tiny `alpine` image (7MB) and only copies the compiled binary over. The heavy build tools from Stage 1 are completely discarded and never make it into the final production image.

---

## ☁️ Task 3 & 4: Push to Docker Hub

I authenticated with Docker Hub via the terminal using my Personal Access Token (PAT).

1. **Login:** `docker login`
2. **Tag:** I tagged my optimized image to match my Docker Hub repository:
   ```bash
   docker tag go-app-multi sachin8550/my-go-app:v1
   ```
3. **Push:** I pushed the image to the cloud registry:
   ```bash
   docker push sachin8550/my-go-app:v1
   ```
4. **Verify:** I visited Docker Hub and confirmed the image and the `v1` tag were visible.

* **Link to my Docker Hub Repo:** [https://hub.docker.com/repository/docker/sachin8550/my-go-app](https://hub.docker.com/repository/docker/sachin8550/my-go-app)

* **Note on Tags:** Pulling `latest` grabs whatever the most recent build was, which can break things if the codebase changes unexpectedly. Pulling a specific tag like `v1` ensures you get the exact version of the code you tested.

---

## 🛡️ Task 5: Image Best Practices

I applied three critical best practices to my Dockerfile:

1. **Minimal Base Image:** Swapped from Ubuntu/Debian to Alpine.
2. **Combined RUN commands:** Using `&&` to combine commands (like `apt-get update && apt-get install`) reduces the total number of layers Docker has to create.
3. **Non-Root User:** Running apps as root inside a container is a security risk. I added a user specifically to run the app.

**Secure & Optimized Dockerfile Example:**
```dockerfile
FROM alpine:latest

# Create a non-root user
RUN adduser -D appuser
WORKDIR /home/appuser

# Copy the app...

# Switch to the non-root user
USER appuser

CMD ["./myapp"]
```
