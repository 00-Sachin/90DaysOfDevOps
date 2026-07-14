# Day 36 – Docker Project: Dockerize a Full Application



## Task 1: Pick Your App
For this project, I chose to Dockerize a Node.js Express application connected to a PostgreSQL database. 

**Why?** This is a highly standard, real-world tech stack. It requires handling environment variables, database connections, and ensuring the application doesn't crash before the database is fully booted up.

## Task 2: Write the Dockerfile
I wrote a secure, optimized, multi-stage Dockerfile for the Node.js application.

### `Dockerfile`
```dockerfile
# STAGE 1: Builder
FROM node:18-alpine AS builder
WORKDIR /app

# Copy package files first to leverage Docker layer caching
COPY package*.json ./
RUN npm install

# Copy the rest of the application code
COPY . .

# STAGE 2: Production
FROM node:18-alpine
WORKDIR /app

# Security: Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only the necessary files from the builder stage
COPY --from=builder /app ./

# Change ownership to the non-root user
RUN chown -R appuser:appgroup /app

# Switch to the non-root user
USER appuser

# Expose the application port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
```
'dockerignore'
```
node_modules
.git
.env
Dockerfile
README.md
```
### Task 3: Add Docker Compose
I created a docker-compose.yml file to orchestrate the Node.js app and the Postgres database, utilizing healthchecks and named volumes.
```
version: '3.8'

services:
  db:
    image: postgres:13-alpine
    restart: always
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_NAME}
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - my-app-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d${DB_NAME}"]
      interval: 10s
      timeout: 5s
      retries: 5

  web:
    image: sachin8550/my-node-app:v1
    build: .
    ports:
      - "3000:3000"
    environment:
      DB_HOST: db
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
      DB_NAME: ${DB_NAME}
    depends_on:
      db:
        condition: service_healthy
    networks:
      - my-app-net

networks:
  my-app-net:

volumes:
  db_data:
```
### Task 4 & 5: Ship It and Test the Flow
Build and Tag: I built the image and tagged it with my Docker Hub username.

 Bash
docker build -t sachin8550/my-node-app:v1 .
Push: I pushed the image to Docker Hub.

Bash
docker push sachin8550/my-node-app:v1
The Ultimate Test: I ran docker system prune -a to delete all my local images and containers. Then, I ran docker compose up -d.

Docker Compose successfully pulled my custom image from Docker Hub, built the database, waited for the healthcheck to pass, and started the app. It worked perfectly on the first try!

