# Issue #3 — Config Server & Discovery Server (Eureka)
**Branch:** `feature/issue-3-config-discovery`  
**JIRA:** [Issue #3 - Configure service discovery and centralized config management](https://github.com/orgs/PetClinic-Project-Team/projects/1/views/2?pane=issue&itemId=184930136&issue=PetClinic-Project-Team%7Cspring-petclinic-microservices%7C3)  
**Owner:** Harini (P4 — Config & Discovery Engineer)  
**Status:** 🟡 In Progress — Pending AWS Account ID and ECR images from team

---

## What Is This Work?

This folder contains the Kubernetes manifests to deploy two critical foundation
services for the Spring PetClinic Microservices application on AWS EKS:

### 1. Config Server (port 8888)
The Config Server is the **first service that must start** in the entire application.
It acts as a central configuration manager — every other microservice (customers,
vets, visits, api-gateway, genai, admin) fetches its settings from here on startup.

It reads all configuration files from this external GitHub repository:
https://github.com/spring-petclinic/spring-petclinic-microservices-config

Without Config Server running and healthy, NO other service can start.

### 2. Discovery Server / Eureka (port 8761)
The Discovery Server is the **second service that must start**.
It is a Eureka service registry — every microservice registers itself here
when it starts up, and the API Gateway uses it to route traffic dynamically.

This is why the team decided to use Spring Boot native services instead of
Kubernetes ConfigMap/DNS — the application is designed around this pattern.
Replacing it would require significant code changes.

The startup dependency chain is:
Config Server → Discovery Server → All other services

---

## Files in This Folder
k8s/
├── config-server/
│   ├── README.md          ← this file
│   ├── deployment.yaml    ← K8s Deployment for config-server
│   └── service.yaml       ← K8s ClusterIP Service on port 8888
└── discovery-server/
├── deployment.yaml    ← K8s Deployment for discovery-server
└── service.yaml       ← K8s ClusterIP Service on port 8761

---

## What Has Been Done ✅

- [x] Cloned team repo and created feature branch `feature/issue-3-config-discovery`
- [x] Ran config-server and discovery-server locally using `docker compose up config-server discovery-server`
- [x] Verified config-server health: `curl http://localhost:8888/actuator/health` → UP
- [x] Verified config-server serves configs: `curl http://localhost:8888/discovery-server/docker` → configs returned from GitHub config repo
- [x] Verified discovery-server health: `curl http://localhost:8761/actuator/health` → UP
- [x] Verified Eureka dashboard at `http://localhost:8761` → loading correctly
- [x] Created K8s folder structure: `k8s/config-server/` and `k8s/discovery-server/`
- [x] Written `k8s/config-server/deployment.yaml` — Deployment with readiness + liveness probes
- [x] Written `k8s/config-server/service.yaml` — ClusterIP Service on port 8888
- [x] Written `k8s/discovery-server/deployment.yaml` — Deployment with initContainer that waits for config-server
- [x] Written `k8s/discovery-server/service.yaml` — ClusterIP Service on port 8761

---

## What Is Pending ⏳

### Needed from P2 (Infrastructure Engineer):

**1. AWS Account ID**
The ECR image URLs in both deployment files currently use a placeholder:
<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/petclinic/spring-petclinic-config-server:latest
<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/petclinic/spring-petclinic-discovery-server:latest
Once you share the AWS Account ID, replace it like this:
```bash
sed -i 's/<ACCOUNT_ID>/YOUR_ACTUAL_ACCOUNT_ID/g' k8s/config-server/deployment.yaml
sed -i 's/<ACCOUNT_ID>/YOUR_ACTUAL_ACCOUNT_ID/g' k8s/discovery-server/deployment.yaml
```

**2. Confirm EKS cluster is running:**
```bash
aws eks update-kubeconfig --name petclinic-cluster --region us-east-1
kubectl get nodes
```

**3. Confirm namespace exists:**
```bash
kubectl get namespace spring-petclinic
# If not created yet:
kubectl create namespace spring-petclinic
```

### Needed from P3 (CI/CD Engineer):

**1. Confirm Docker images are built and pushed to ECR:**
```bash
aws ecr list-images --repository-name petclinic/spring-petclinic-config-server --region us-east-1
aws ecr list-images --repository-name petclinic/spring-petclinic-discovery-server --region us-east-1
```

**2. Confirm image tag being used** (latest or specific version)

---

## Why Is AWS Account ID Required?

AWS ECR (Elastic Container Registry) is a private Docker image registry.
The full image URL format is:
<account-id>.dkr.ecr.<region>.amazonaws.com/<repo-name>:<tag>

The Account ID is unique to your AWS account and is part of the ECR URL.
Without it, Kubernetes cannot pull the Docker images and the pods will
fail with `ImagePullBackOff` error.

The ECR repositories are already created by P2 via Terraform:
- `petclinic/spring-petclinic-config-server`
- `petclinic/spring-petclinic-discovery-server`

We just need the Account ID to complete the full URL.

---

## How to Test Once Details Are Available

### Prerequisites
- kubectl installed and configured
- AWS CLI configured with access to the shared AWS account
- EKS cluster running (`petclinic-cluster` in `us-east-1`)
- ECR images pushed by P3

### Step 1 — Get the branch
```bash
git fetch origin
git checkout feature/issue-3-config-discovery
```

### Step 2 — Replace Account ID
```bash
# Replace <ACCOUNT_ID> with the real AWS account ID from P2
sed -i 's/<ACCOUNT_ID>/123456789012/g' k8s/config-server/deployment.yaml
sed -i 's/<ACCOUNT_ID>/123456789012/g' k8s/discovery-server/deployment.yaml
```

### Step 3 — Connect to EKS
```bash
aws eks update-kubeconfig --name petclinic-cluster --region us-east-1
kubectl get nodes  # Should show nodes in Ready state
```

### Step 4 — Deploy Config Server first
```bash
kubectl apply -f k8s/config-server/deployment.yaml
kubectl apply -f k8s/config-server/service.yaml

# Wait for it to be ready
kubectl rollout status deployment/config-server -n spring-petclinic
```

### Step 5 — Deploy Discovery Server
```bash
kubectl apply -f k8s/discovery-server/deployment.yaml
kubectl apply -f k8s/discovery-server/service.yaml

# Wait for it to be ready
kubectl rollout status deployment/discovery-server -n spring-petclinic
```

### Step 6 — Verify Both Are Running
```bash
kubectl get pods -n spring-petclinic
# Expected output:
# NAME                                READY   STATUS    RESTARTS   AGE
# config-server-xxxx                  1/1     Running   0          2m
# discovery-server-xxxx               1/1     Running   0          1m
```

### Step 7 — Check Logs
```bash
# Config server logs
kubectl logs -n spring-petclinic -l app=config-server --tail=20

# Discovery server logs
kubectl logs -n spring-petclinic -l app=discovery-server --tail=20
```

### Step 8 — Open Eureka Dashboard
```bash
kubectl port-forward -n spring-petclinic svc/discovery-server 8761:8761
```
Then open browser: `http://localhost:8761`

You should see the Eureka dashboard with discovery-server registered.
As other team members deploy their services, they will appear here too.

---

## Acceptance Criteria (from JIRA Issue #3)

- [ ] All services register with Eureka
- [ ] Config server serves correct configs per environment
- [ ] Services can discover each other dynamically

---

## Useful Debug Commands
```bash
# Check pod status
kubectl get pods -n spring-petclinic

# Describe a pod if it's not starting
kubectl describe pod -n spring-petclinic -l app=config-server
kubectl describe pod -n spring-petclinic -l app=discovery-server

# Check events for errors
kubectl get events -n spring-petclinic --sort-by='.lastTimestamp'

# Restart a deployment
kubectl rollout restart deployment/config-server -n spring-petclinic
kubectl rollout restart deployment/discovery-server -n spring-petclinic
```

---

## Local Testing (Without EKS)
Both services have been verified locally using Docker Compose:
```bash
docker compose up config-server discovery-server
```
- Config Server: http://localhost:8888/actuator/health → `{"status":"UP"}`
- Discovery Server: http://localhost:8761 → Eureka dashboard loads
- Config serving verified: http://localhost:8888/discovery-server/docker → configs returned
