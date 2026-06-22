# Day 34 – Docker Compose: Real-World Multi-Container Apps

## 🏗️ Task 1: Build Your Own App Stack

I built a 3-tier architecture using a Python Flask application that connects to both a Redis cache and a PostgreSQL database.

**`app/app.py`**
```python
from flask import Flask
from redis import Redis
import os
import psycopg2

app = Flask(__name__)
redis = Redis(host='redis', port=6379)

@app.route('/')
def hello():
    # Example logic: increment cache counter
    count = redis.incr('hits')
    return f"Hello World! This page has been seen {count} times."

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

**`app/Dockerfile`**
```dockerfile
FROM python:3.9-slim
WORKDIR /code
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

---

## 🩺 Task 2: depends_on & Healthchecks

To ensure the Python app didn't crash trying to connect to a database that wasn't ready yet, I added healthchecks to the database and told the app to wait.

**`docker-compose.yml` (Snippet)**
```yaml
  db:
    image: postgres:13
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U myuser -d mydatabase"]
      interval: 10s
      timeout: 5s
      retries: 5

  web:
    build: ./app
    depends_on:
      db:
        condition: service_healthy
```

**Test Result:** When I ran `docker compose up -d`, Docker started the database first, continuously polled it with `pg_isready`, and only started the web container once the DB reported back as "healthy."

---

## 🔄 Task 3: Restart Policies

I tested the resilience of the stack by adding `restart: always` to my database service.

* **Test:** I manually killed the database container using `docker kill <container_id>`.
* **Result:** Docker immediately detected the container had stopped and spun it right back up without any manual intervention!

**Restart Policy Differences:**
* `always`: Docker will always restart the container if it stops, even if you stop it manually (unless the Docker daemon itself restarts). Good for critical infrastructure like databases.
* `on-failure`: Docker only restarts the container if it exits with a non-zero exit code (meaning it crashed). If you manually stop it gracefully (exit code 0), it stays stopped. Best for applications or worker scripts.

---

## 🛠️ Task 4: Custom Dockerfiles in Compose

Instead of pre-building my Python image manually with `docker build`, I used the `build: ./app` directive in my Compose file.

**Observation:** When I made a code change to `app.py`, I simply ran `docker compose up --build -d`. Compose detected the change, rebuilt the local image on the fly, and recreated only the web container while leaving the database untouched.

---

## 🕸️ Task 5: Named Networks & Volumes

I formalized the infrastructure by defining explicit networks and persistent volumes.

**`docker-compose.yml` (Network & Volume definitions)**
```yaml
networks:
  frontend:
  backend:

volumes:
  pgdata:
```

I attached the `web` and `redis` containers to `frontend`, and the `web` and `db` containers to `backend`, tightly controlling which services could talk to each other.

---

## 📈 Task 6: Scaling (Bonus)

I attempted to scale my web app to 3 replicas using:
```bash
docker compose up --scale web=3 -d
```

**What broke?**
I received a `bind: address already in use` error for port `5000`.

**Why?** Simple scaling fails when using static port mapping (`ports: "5000:5000"`). The first replica binds to my host's port 5000 perfectly. But when the second and third replicas try to start, they also try to bind to my host's port 5000, which is already taken by the first replica.

**Solution:** To scale properly, you either map to a dynamic port (`ports: -"5000"`) or use a Reverse Proxy/Load Balancer (like Nginx or Traefik) to sit in front of the replicas and distribute traffic to them on a single host port.
