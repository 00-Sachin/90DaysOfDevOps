## 2. Docker Hub & Status Badge

* **Docker Hub Link:** [sachinkrc/github-actions-practice](https://hub.docker.com/repository/docker/sachinkrc/github-actions-practice/general)
* **Badge:** [![Docker Build and Publish](https://github.com/00-Sachin/Git-Hub-Actions-Practice/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/00-Sachin/Git-Hub-Actions-Practice/actions)
  *(I added this to my main README.md file!)*

---

## 3. The Full Journey: From Git Push to a Running Container

Here is the step-by-step lifecycle of exactly what happens when I push code:

1. **The Code Push:** I write code on my laptop and run `git push origin main`.
2. **The Trigger:** GitHub Actions detects the push to the `main` branch and spins up an `ubuntu-latest` cloud server (runner).
3. **The Preparation:** The runner checks out my code, calculates the short commit SHA (for version tracking), and authenticates into my Docker Hub account using my hidden secrets.
4. **The Build:** The runner executes my `Dockerfile`, building the lightweight Nginx image and tagging it twice (with `latest` and `sha-1234567`).
5. **The Push:** Because the push was on the `main` branch, the runner pushes both tagged images to Docker Hub. *(If I pushed to a feature branch, it would build to test for errors, but skip the push).*
6. **The Deployment (Local):** I go to my local machine terminal and run `docker run -d -p 8080:80 sachinkrc/github-actions-practice:latest`. The image pulls instantly, and my updated app is live!
