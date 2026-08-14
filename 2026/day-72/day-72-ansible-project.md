# Day 72 — Ansible Docker & Nginx Project

## Project Overview

This project combined the Ansible concepts learned throughout Days 68–72 into one practical deployment.

The goal was to use **Ansible to provision and configure a web server**, install Docker and Nginx, deploy a Dockerized application, protect Docker Hub credentials with **Ansible Vault**, and configure Nginx as a reverse proxy in front of the Docker container.

The final architecture was:

```text
                    Ansible Controller
                           |
                           | SSH / Ansible
                           v
                    +---------------+
                    |   Web Server   |
                    |     EC2       |
                    +-------+-------+
                            |
                            | Port 80
                            v
                    +---------------+
                    |     Nginx     |
                    | Reverse Proxy |
                    +-------+-------+
                            |
                            | Port 8080
                            v
                    +---------------+
                    | Docker        |
                    | Application   |
                    | Container     |
                    +---------------+
```

In the final test, the Docker application was changed from the original application to `httpd:latest`. Nginx continued to proxy traffic without requiring an Nginx configuration change.

---

# 1. What We Built

The project was organized using Ansible roles.

A simplified structure was:

```text
ansible-docker-project/
├── ansible.cfg
├── inventory.ini
├── site.yml
├── .vault_pass
├── group_vars/
│   ├── all.yml
│   └── web/
│       └── vault.yml
└── roles/
    ├── docker/
    │   ├── defaults/
    │   ├── tasks/
    │   └── ...
    └── nginx/
        ├── defaults/
        ├── handlers/
        ├── tasks/
        └── templates/
```

The main responsibilities were:

### Docker role

- Install Docker dependencies.
- Install Docker Engine and related plugins.
- Start and enable Docker.
- Add the `deploy` user to the Docker group.
- Log in to Docker Hub using Vault-protected credentials.
- Pull the required Docker image.
- Run the application container.
- Check that the application is responding.

### Nginx role

- Install Nginx.
- Remove the default Nginx site.
- Deploy the main `nginx.conf`.
- Deploy the reverse-proxy configuration.
- Test the Nginx configuration.
- Start and enable Nginx.
- Reload Nginx when configuration changes.

---

# 2. Ansible Configuration

The `ansible.cfg` configured the inventory, SSH connection, private key, host-key behavior, and Vault password file.

Example:

```ini
[defaults]
inventory = inventory.ini
remote_user = Ubuntu
private_key_file = ../terra-ansible.pem
host_key_checking = False
vault_password_file = .vault_pass
```

The important point is that `.vault_pass` is referenced as a password-file path. It does not have to have a special mandatory location; the configured path determines where Ansible looks for it.

The password file should **never be committed to Git**.

Example `.gitignore` entry:

```gitignore
.vault_pass
```

---

# 3. Ansible Vault

Docker Hub credentials were sensitive information, so they were not stored directly in normal variables.

Instead, the credentials were stored in an encrypted Vault file:

```text
group_vars/web/vault.yml
```

The file begins with:

```text
$ANSIBLE_VAULT;1.1;AES256
```

This confirms that it is encrypted with Ansible Vault.

The Docker role then referenced variables such as:

```yaml
username: "{{ vault_docker_username }}"
password: "{{ vault_docker_password }}"
```

This allowed the playbook to use the credentials without placing the plaintext password directly in the role.

## Important Vault lesson

The Vault password is different from the encrypted contents.

If an existing Vault file cannot be decrypted:

```text
Decryption failed (no vault secrets were found that could decrypt)
```

then the password supplied to Ansible does not match the password originally used to encrypt the file.

A Vault password cannot simply be replaced without knowing the old password. If the old encrypted data is no longer needed, a new Vault can be created instead.

---

# 4. Selective Deployment with Tags

Tags were used throughout the roles.

For example:

```yaml
tags:
  - docker
```

and:

```yaml
tags:
  - nginx
```

This allowed only part of the project to be deployed.

For example, to deploy only the Docker-related tasks:

```bash
ansible-playbook site.yml --tags docker
```

To deploy only Nginx:

```bash
ansible-playbook site.yml --tags nginx
```

This is useful because we do not always need to execute the entire infrastructure configuration.

For example:

```text
Full deployment
    |
    +-- Docker tasks
    |
    +-- Nginx tasks
    |
    +-- Other roles
```

Tags allow us to select only the required branch.

We also used extra variables with selective deployment:

```bash
ansible-playbook site.yml --tags docker \
  -e "docker_app_image=httpd docker_app_tag=latest docker_app_name=apache-app"
```

This changed the deployed application without modifying the role itself.

---

# 5. Docker Application Deployment

The Docker role used the Docker modules from the `community.docker` collection.

The important operations were:

```text
community.docker.docker_login
community.docker.docker_image
community.docker.docker_container
```

The container was exposed using a host-to-container port mapping.

The intended mapping was:

```text
Host port 8080 -> Container port 80
```

For Apache/httpd:

```text
8080:80
```

Therefore:

```text
EC2/Web Server :8080
        |
        v
Docker Container :80
        |
        v
Apache httpd
```

---

# 6. Nginx Reverse Proxy

Nginx was configured to listen on port 80 and forward requests to the Docker application on port 8080.

The upstream configuration was conceptually:

```nginx
upstream docker_app {
    server 127.0.0.1:8080;
}
```

The server block then forwarded requests:

```nginx
location / {
    proxy_pass http://docker_app;
}
```

The final request path was:

```text
Internet
   |
   | :80
   v
Nginx
   |
   | 127.0.0.1:8080
   v
Docker Container
   |
   | :80
   v
Application
```

This means users do not need to access the application directly on port 8080.

Port 8080 can remain inaccessible from the public Internet while Nginx exposes the application through port 80.

---

# 7. Problems We Faced and How They Were Solved

## Problem 1 — Vault decryption failed

Error:

```text
Decryption failed (no vault secrets were found that could decrypt)
```

The Vault file was valid:

```text
$ANSIBLE_VAULT;1.1;AES256
```

but the password in `.vault_pass` did not match the password used to encrypt the file.

### Lesson

The Vault file and Vault password must match.

If the old password is known, use `ansible-vault rekey`.

If the old password is completely lost and the encrypted data is not needed, create a new Vault.

---

## Problem 2 — `.vault_pass` location

The project used:

```ini
vault_password_file = .vault_pass
```

This means Ansible used the configured `.vault_pass` file.

There is no universal mandatory location for the Vault password file. The location is determined by the path configured in `ansible.cfg` or supplied on the command line.

### Lesson

Keep the Vault password file secure and exclude it from Git.

---

## Problem 3 — Ansible temporary-file permission error

We initially saw:

```text
Failed to set permissions on the temporary files Ansible needs to create
when becoming an unprivileged user
```

with:

```text
chmod: invalid operator
```

The problem was reproduced even with a simple:

```bash
ansible web -m command -a "whoami" --become --become-user deploy
```

This proved that the problem was not caused by Docker.

The task was using:

```yaml
become: true
become_user: deploy
```

Ansible was connecting as the `Ubuntu` user and becoming the unprivileged `deploy` user.

The solution was to install the `acl` package on the remote server so Ansible could use the appropriate ACL mechanism for temporary files.

Example:

```yaml
- name: Install Docker dependencies
  ansible.builtin.apt:
    name:
      - ca-certificates
      - curl
      - acl
    state: present
    update_cache: true
```

### Lesson

When Ansible needs to become another unprivileged user, temporary-file permissions can become important. The `acl` package provides `setfacl`, which helps Ansible handle this securely.

---

## Problem 4 — Nginx configuration had no `events` section

Error:

```text
no "events" section in configuration
```

The cause was that:

```text
roles/nginx/templates/nginx.conf.j2
```

was empty.

Nginx requires a valid top-level configuration structure.

The main configuration was therefore created with an `events` block and an `http` block.

Example:

```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    sendfile on;
    keepalive_timeout 65;

    include /etc/nginx/conf.d/*.conf;
}
```

### Lesson

The main `nginx.conf` and the application reverse-proxy configuration have different responsibilities.

`nginx.conf` provides the main Nginx structure.

`app-proxy.conf` provides the application-specific reverse proxy.

---

## Problem 5 — Port 8080 was already allocated

When changing the application to Apache, Docker reported:

```text
Bind for 0.0.0.0:8080 failed: port is already allocated
```

The old application container was still using port 8080.

Two containers cannot simultaneously bind the same host port:

```text
old-app    -> :8080
apache-app -> :8080
```

The old container needed to be removed/replaced before the new container could use the port.

### Lesson

Host ports must be unique.

When replacing an application, the old container must release the port before the new container starts.

---

## Problem 6 — Apache container was running but health check failed

The container showed:

```text
apache-app   httpd:latest   ...   Up
```

but the Ansible health check reported:

```text
Connection refused
```

We discovered that the container had no host port mapping.

The important mapping was:

```text
8080:80
```

After the correct mapping was applied, the application became reachable through the host.

### Lesson

A running Docker container does not automatically mean that the application is reachable from the host.

Always verify:

```bash
docker ps
docker port apache-app
curl http://localhost:8080
```

---

# 8. Verifying the Final Architecture

We tested the application directly:

```bash
curl -i http://localhost:8080
```

Then tested Nginx:

```bash
curl -i http://localhost
```

The Nginx response contained:

```text
Server: nginx/1.28.3
```

while the HTML content came from Apache:

```text
It works! Apache httpd
```

This proved that Nginx was successfully reverse proxying to the Docker container.

The final path was:

```text
curl/browser
      |
      | :80
      v
   Nginx
      |
      | :8080
      v
Docker apache-app
      |
      | :80
      v
Apache httpd
```

---

# 9. Why Port 8080 Did Not Work from the Public IP

Testing:

```text
http://PUBLIC_IP:8080
```

from Chrome did not work, while:

```text
http://PUBLIC_IP
```

worked.

This was expected when port 8080 is not allowed by the cloud firewall/security group.

The desired production-style architecture is:

```text
Internet
   |
   | 80 / 443
   v
Nginx
   |
   | internal application port
   v
Docker
```

There is no requirement to expose the application port directly to the Internet.

This is safer because Nginx becomes the public entry point.

---

# 10. Idempotency

The full playbook was run again after deployment:

```bash
ansible-playbook site.yml
```

A successful idempotent playbook should show mostly:

```text
ok
```

with zero or minimal:

```text
changed
```

and:

```text
failed=0
```

Idempotency means running the same playbook multiple times should converge the server toward the desired state without unnecessarily changing resources that are already correct.

This is one of the most important characteristics of configuration management with Ansible.

---

# 11. Important Commands Learned

### Run the complete project

```bash
ansible-playbook site.yml
```

### Run only Docker tasks

```bash
ansible-playbook site.yml --tags docker
```

### Run only Nginx tasks

```bash
ansible-playbook site.yml --tags nginx
```

### Override variables

```bash
ansible-playbook site.yml --tags docker \
  -e "docker_app_image=httpd docker_app_tag=latest docker_app_name=apache-app"
```

### Test Nginx configuration

```bash
nginx -t
```

### Check Docker containers

```bash
docker ps
```

### Check Docker port mapping

```bash
docker port apache-app
```

### Test the application directly

```bash
curl http://localhost:8080
```

### Test through Nginx

```bash
curl http://localhost
```

### View Docker logs

```bash
docker logs apache-app
```

---

# 12. Tools Used and Their Purpose

| Tool | Purpose |
|---|---|
| **Terraform** | Provisioned the EC2/infrastructure environment |
| **Ansible** | Automated server configuration and deployment |
| **Ansible Vault** | Protected Docker Hub credentials |
| **Ansible Roles** | Organized Docker and Nginx configuration |
| **Jinja2 Templates** | Generated dynamic Nginx configuration |
| **Ansible Tags** | Allowed selective deployment |
| **Docker** | Ran the application container |
| **Docker Hub** | Provided the container image |
| **Nginx** | Served as the reverse proxy |
| **curl** | Tested application and proxy connectivity |
| **Git/GitHub** | Version-controlled the project |

---

# 13. Day 68–72 Concept Mapping

| Day | Concepts Used in Day 72 |
|---|---|
| **68** | Inventory, ad-hoc commands, SSH setup |
| **69** | Playbooks, modules, handlers |
| **70** | Variables, facts, conditionals, loops |
| **71** | Roles, templates, Galaxy, Vault |
| **72** | Everything combined into one complete project |

---

# 14. What Should Be Added for Production?

The project is a learning environment. A production deployment would need additional components.

## SSL/TLS

Use HTTPS with a trusted certificate, for example through Let's Encrypt and Certbot.

```text
Internet
   |
 HTTPS :443
   |
 Nginx
```

## Monitoring

Monitor:

- CPU
- Memory
- Disk
- Docker containers
- Nginx
- Application health

Prometheus and Grafana could be introduced for monitoring and visualization.

## Log Rotation

Configure log rotation for:

- Nginx logs
- Docker logs
- Application logs

This prevents logs from consuming all available disk space.

## Multi-container deployment

For a larger application, Docker Compose could manage:

```text
Nginx
Application
Database
Redis/cache
```

## CI/CD

The deployment could eventually become:

```text
Developer
   |
   v
GitHub
   |
   v
GitHub Actions
   |
   +--> Test
   |
   +--> Build Docker image
   |
   +--> Push image to Docker Hub
   |
   v
Ansible
   |
   v
EC2
   |
   v
Nginx -> Docker Application
```

---

# 15. Cleanup

After completing the project, cloud resources should be removed to avoid unnecessary costs.

If Terraform created the infrastructure:

```bash
terraform destroy
```

If the EC2 instances were created manually, terminate them from the cloud console.

Also check for other resources that may continue generating charges, such as:

- Elastic IPs
- EBS volumes
- Load balancers
- NAT gateways
- Other manually created resources

---

# 16. Things to Remember

1. **Vault protects secrets, but the Vault password itself must also be protected.**
2. **Never commit `.vault_pass` to Git.**
3. **Use tags when only one part of the infrastructure needs to be changed.**
4. **A running container does not guarantee that its port is accessible. Always verify the port mapping.**
5. **A host port can only be bound by one container at a time.**
6. **Nginx can hide the application's internal port from the public Internet.**
7. **`nginx -t` should be used to validate configuration before relying on a reload.**
8. **Templates separate configuration data from Ansible task logic.**
9. **Handlers allow services to reload/restart only when configuration changes.**
10. **Idempotency is essential: running the same playbook repeatedly should not cause unnecessary changes.**
11. **When becoming an unprivileged user, Ansible may need ACL support (`acl`/`setfacl`) for secure temporary-file handling.**
12. **When replacing Docker applications, make sure the old container releases the required host port.**
13. **The reverse proxy should normally be the public entry point rather than exposing the application port directly.**

---

# Final Architecture

```text
                         Git / GitHub
                              |
                              v
                     Ansible Controller
                              |
                              | SSH
                              v
                     +------------------+
                     |   EC2 Web Server |
                     +---------+--------+
                               |
                         Port 80/443
                               |
                               v
                     +------------------+
                     |      Nginx       |
                     | Reverse Proxy    |
                     +---------+--------+
                               |
                         127.0.0.1:8080
                               |
                               v
                     +------------------+
                     | Docker Container |
                     |   Apache/httpd   |
                     |       :80        |
                     +------------------+

          Credentials
               |
               v
        Ansible Vault
               |
               v
       Docker Hub Login
```

## Final Result

The project demonstrated how the Ansible concepts learned from Days 68–72 can be combined into a complete deployment workflow:

**Infrastructure → Ansible → Docker → Nginx → Application**

The application could be replaced without changing the Nginx reverse-proxy configuration, selective deployment was possible through tags, sensitive credentials were protected with Vault, and the final playbook could be rerun to verify idempotency.
