# Day 66: AWS EKS with Terraform - Documentation

## 1. Provisioning the EKS Cluster
The EKS cluster was provisioned using Terraform. The essential configuration involved setting up the AWS provider, defining the VPC, and using the `aws_eks_cluster` and node group resources. 

**Terraform execution steps:**
```bash
terraform init
terraform plan
terraform apply --auto-approve
```

## 2. Documenting Connection & Authentication Issues

During the connection phase, two major issues were encountered and resolved.

### Issue A: DNS Resolution Error
**Symptom:** `dial tcp: lookup ... eks.amazonaws.com ... no such host`
**Root Cause:** The local `~/.kube/config` contained outdated cluster information (e.g., from a previous `terraform destroy`).
**Resolution:** Updated the kubeconfig file with the new cluster's endpoint.
```bash
aws eks update-kubeconfig --region us-west-1 --name terraweek-eks
```

### Issue B: Kubernetes RBAC Authentication Error
**Symptom:** `error: You must be logged in to the server (the server has asked for the client to provide credentials)`
**Root Cause:** Amazon EKS grants initial `cluster-admin` access only to the exact IAM entity that created the cluster. The local IAM user (`sachin_dev`) was not the original creator, thus lacking Kubernetes RBAC permissions.
**Resolution:** Created an EKS Access Entry via the AWS Management Console mapping the IAM user (`sachin_dev`) to the EKS cluster and attached the `AmazonEKSClusterAdminPolicy`.

## 3. Deploying and Exposing the Application

After securing access, a sample Nginx application was deployed and exposed to the internet.

**Deployment Steps:**
```bash
# Deploy Nginx
kubectl create deployment nginx-app --image=nginx

# Expose via AWS Elastic Load Balancer
kubectl expose deployment nginx-app --port=80 --type=LoadBalancer

# Retrieve the LoadBalancer URL
kubectl get svc nginx-app
```
*Result: The Nginx welcome page was successfully accessed via the LoadBalancer's `EXTERNAL-IP` URL.*

## 4. Resource Cleanup and Verification

To prevent unexpected AWS charges, it is critical to verify the removal of the LoadBalancer when destroying resources.

**Cleanup Steps:**
```bash
# Delete the Kubernetes service (triggers ELB deletion)
kubectl delete -f nginx-deployment.yaml
```

**Verification:**
Checked if the ELB was successfully removed using the AWS console:
