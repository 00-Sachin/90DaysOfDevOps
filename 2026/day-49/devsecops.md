# Day 49 – DevSecOps: Add Security to Your CI/CD Pipeline

## 1. What is DevSecOps?
DevSecOps is the practice of integrating automated security checks directly into the CI/CD pipeline rather than treating security as a separate, final step. By automating vulnerability and secret scans during the pull request and build stages, development teams can catch and resolve critical security issues in minutes before they ever reach the production environment.

## 2. Docker Image Vulnerability Scan (Trivy)
We integrated `aquasecurity/trivy-action` into the main deployment pipeline to scan the Docker image before pushing it to the registry. 
*   **Base Image Used:** `node:18-alpine` *(Update with your actual base image)*
*   **CVEs Found:** 0 CRITICAL or HIGH vulnerabilities were detected in this run, allowing the pipeline to proceed and deploy. *(Update with actual findings if any)*


## 2. GitHub Secret Scanning & Push Protection
*   **Secret Scanning vs. Push Protection:** Secret scanning continuously monitors the repository and alerts you if a secret (like an API key or password) is found in the codebase after it has been pushed. Push protection is a proactive measure that scans commits *before* they are accepted; if it detects a secret, it completely blocks the push to the repository.
*   **Leaked AWS Key Scenario:** If GitHub detects a leaked AWS key in the repository, it immediately flags it as a security alert. Thanks to GitHub's partner program, it also directly notifies AWS, which can automatically quarantine or revoke the compromised key to prevent unauthorized access to cloud resources.

## 3. Dependency Vulnerability Review
By adding `actions/dependency-review-action@v4` to the Pull Request pipeline, the workflow now automatically intercepts any new dependencies added in a PR. If a developer attempts to merge a package with a known critical CVE, the PR check will fail, preventing the insecure dependency from entering the main codebase.

## 4. Workflow Permissions
*   **Why limit permissions?** Limiting workflow permissions enforces the principle of least privilege. By default, workflows might have broad access to modify the repository. Explicitly defining `permissions: contents: read` ensures the workflow only has exactly the access it needs to run.
*   **The Risk:** If a compromised or malicious third-party GitHub Action has `write` access, it could secretly modify source code, steal environment variables, or push malicious releases directly to the repository.

## 5. The Full Secure DevSecOps Pipeline Diagram

```text
[ Pull Request Opened ]
       │
       ├─► Build & Test
       ├─► Dependency Vulnerability Check  <-- [NEW]
       │
       └─► PR Checks (Pass/Fail)

[ Merge to Main ]
       │
       ├─► Build & Test
       ├─► Docker Build
       ├─► Trivy Image Scan (Fails on CRITICAL/HIGH)  <-- [NEW]
       ├─► Docker Push (Only if scan passes)
       │
       └─► Deploy to Production

[ Always Active (Background) ]
       │
       ├─► GitHub Secret Scanning          <-- [NEW]
       └─► Push Protection for Secrets     <-- [NEW]
