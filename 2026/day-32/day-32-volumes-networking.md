# Day 32 – Docker Volumes & Networking


## ⚠️ Task 1: The Problem (Ephemeral Data)

I started by running a MySQL database container and logging into it. I created a database called `testdb` and verified it existed. Then, I stopped the container and permanently removed it (`docker rm -f mysql-db`).

I spun up a brand new MySQL container using the exact same image. When I logged in and ran `SHOW DATABASES;`, my `testdb` was gone!

**Why?** Containers are ephemeral (temporary). When a container is deleted, its writable layer is destroyed along with it. To save data permanently, we must store it outside the container.

---

## 💾 Task 2: Named Volumes

To fix the data loss problem, I used a **Named Volume**:

1. **Created a volume:** `docker volume create mydb-data`
2. **Attached it to a new MySQL container:**
   ```bash
   docker run -d --name mysql-db -v mydb-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=sachin mysql
   ```

I logged in, created a database named `new_test`, stopped, and removed the container. 
I spun up a brand new container but attached the exact same `mydb-data` volume.

**Result:** My `new_test` database was still there! The data survived the container's destruction.

---

## 🔗 Task 3: Bind Mounts

Instead of letting Docker manage the volume somewhere hidden on my hard drive, I used a **Bind Mount** to explicitly link a folder on my actual machine to the container.

I created an `index.html` file in my local `~/scripts/html/` folder and ran Nginx:
```bash
docker run -d --name my-nginx -p 8080:80 -v ~/scripts/html:/usr/share/nginx/html nginx
```

When I accessed `localhost:8080`, I saw my webpage. The best part? When I edited the `index.html` file on my host machine and refreshed my browser, the changes appeared instantly without rebuilding or restarting the container!

### Difference between Named Volumes and Bind Mounts:
* **Named Volume:** Docker manages the storage location entirely. Best for database files where you just want data to persist safely.
* **Bind Mount:** You specify the exact folder path on your host machine. Best for active development (like coding a website) so you can see live changes instantly.

---

## 🌐 Task 4: Docker Networking Basics

I explored the default `bridge` network. I ran two generic containers (`c1` and `c2`) on the default bridge.

* **Could they ping each other by IP?** Yes.
* **Could they ping each other by Name?** No.

---

## 🛠️ Task 5: Custom Networks

I created a custom network: 
```bash
docker network create my-app-net
```

I ran two new containers (`app1` and `app2`) and attached them to this custom network using `--network my-app-net`.

* **Could they ping each other by Name?** YES! `ping app2` from inside `app1` worked perfectly.

**Why does custom networking allow name-based communication?**
The default Docker bridge network does not provide automatic DNS resolution (for legacy/backward compatibility reasons). However, user-defined custom networks come with a built-in DNS server that automatically resolves container names to their IP addresses.

---

## 🧩 Task 6: Put It Together

I simulated a real multi-tier architecture using a single command block:

1. I used my custom network (`my-app-net`).
2. I launched a database:
   ```bash
   docker run -d --name my-database --network my-app-net -v mydb-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=sachin mysql
   ```
3. I launched an app container on the same network:
   ```bash
   docker run -d --name my-app --network my-app-net ubuntu sleep infinity
   ```
4. I executed into `my-app` and successfully pinged the database using only its name: `ping my-database`.

This proves that I can run an application and a database completely isolated from each other, yet they can communicate seamlessly using Docker's internal DNS, while the database data remains perfectly safe on a volume!
