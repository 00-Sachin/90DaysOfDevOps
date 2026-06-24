# 🐳 Docker Cheat Sheet

## 📦 Container Commands
- `docker run -it <image>` : Run a container in interactive mode (with terminal)
- `docker run -d <image>` : Run a container in detached mode (background)
- `docker ps` : List running containers (`-a` for all, including stopped)
- `docker stop <container>` : Gracefully stop a running container
- `docker rm <container>` : Remove a stopped container (`-f` to force remove a running one)
- `docker exec -it <container> sh` : Open a shell inside a running container
- `docker logs <container>` : View container logs (`-f` to follow live)

## 🖼️ Image Commands
- `docker build -t <name>:<tag> .` : Build an image from a Dockerfile in the current directory
- `docker pull <image>` : Download an image from Docker Hub / registry
- `docker push <image>` : Upload an image to Docker Hub / registry
- `docker tag <source> <target>` : Create an alias/tag for an image
- `docker images` : List all local images
- `docker rmi <image>` : Remove a local image

## 💾 Volume Commands
- `docker volume create <name>` : Create a named volume for persistent data
- `docker volume ls` : List all volumes
- `docker volume inspect <name>` : Show detailed information about a volume
- `docker volume rm <name>` : Remove a specific volume

## 🌐 Network Commands
- `docker network create <name>` : Create a custom local network
- `docker network ls` : List all networks
- `docker network inspect <name>` : View containers connected to a network
- `docker network connect <network> <container>` : Connect a running container to a network

## 🐙 Compose Commands
- `docker compose up -d` : Start all services defined in `docker-compose.yml` in the background
- `docker compose down` : Stop and remove containers and networks
- `docker compose down -v` : Stop and remove containers, networks, **and volumes**
- `docker compose ps` : List running compose services
- `docker compose logs -f` : View trailing logs for all services combined
- `docker compose build` : Build or rebuild services

## 🧹 Cleanup Commands
- `docker system prune` : Remove stopped containers, dangling images, and unused networks
- `docker system prune -a --volumes` : ⚠️ **Deep clean**: Removes ALL unused images and volumes
- `docker system df` : Show disk usage by Docker

## 📄 Dockerfile Instructions
- `FROM` : Specifies the base image (Must be the first instruction)
- `WORKDIR` : Sets the default working directory for subsequent instructions
- `COPY` : Copies files/directories from the host into the container
- `ADD` : Similar to `COPY`, but extracts `.tar` files and supports remote URLs
- `RUN` : Executes terminal commands during the build process (e.g., `npm install`)
- `EXPOSE` : Documents the port the container listens on (does not actually publish it)
- `ENV` : Sets environment variables
- `CMD` : The default command to execute when the container starts (can be overridden)
- `ENTRYPOINT` : The main executable for the container (arguments are appended to it)
