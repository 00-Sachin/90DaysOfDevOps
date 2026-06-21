# Day 33 – Docker Compose: Multi-Container Basics



## ⚙️ Task 1: Install & Verify

I verified my Docker Compose installation by running `docker compose version`.

**Result:** Docker Compose version `v2.27.0` was confirmed installed and ready to use.

---

## 📝 Task 2: Your First Compose File

I created a simple `docker-compose.yml` to spin up a single Nginx web server.

**`compose-basics/docker-compose.yml`**
```yaml
services:
  web:
    image: nginx
    ports:
      - "80:80"
```

### Troubleshooting the Port Conflict:
When I ran `docker compose up`, I encountered a `bind: address already in use` error for port `80`.

* I checked my host system using `curl localhost:80` and `ps -ef | grep nginx` to confirm Nginx was already running natively.
* I stopped the local service: `sudo systemctl stop nginx`.
* I found another rogue container holding the port using `docker ps` and killed it.

After clearing the port, `docker compose up` worked perfectly, and my containerized Nginx server came online!

---

## 🐳 Task 3: Two-Container Setup (WordPress + MySQL)

I created a multi-tier application using a single Compose file. This automatically handles networking and DNS resolution between the services.

**`wordpress-mysql/docker-compose.yml`**
```yaml
services:
  db:
    image: mysql:8.0
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: somewordpress
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpresspassword

  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    ports:
      - "8000:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpresspassword
      WORDPRESS_DB_NAME: wordpress

volumes:
  db_data:
```

**Observation:**
* I ran `docker compose up -d` and accessed the WordPress installation screen on `localhost:8000`.
* **Data Persistence Verification:** I stopped and destroyed the containers using `docker compose down`. When I ran `docker compose up -d` again, my WordPress setup and data were perfectly intact because I used the `db_data` named volume attached to the MySQL container!

---

## 💻 Task 4: Compose Commands

I practiced essential Compose management commands:

* `docker compose up -d`: Starts all services in the background (detached mode).
* `docker compose ps`: Views the running services specifically linked to the current Compose file.
* `docker compose logs -f`: Views live logs of all services.
* `docker compose logs db`: Views logs specific to the database service.
* `docker compose stop`: Stops the services but leaves the containers intact.
* `docker compose down`: Stops the services, destroys the containers, and destroys the custom network. *(Add `-v` to also destroy volumes)*.

---

## 🔐 Task 5: Environment Variables

I created a `.env` file to securely store my database credentials instead of hardcoding them into the `docker-compose.yml` file.

**`.env` file:**
```env
DB_PASSWORD=my_secure_password
```

**Updated `docker-compose.yml` section:**
```yaml
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD}
```

**Observation:** Docker Compose automatically reads the `.env` file in the same directory and substitutes the variables during startup, keeping sensitive credentials out of version control.
