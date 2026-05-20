# Spring PetClinic Microservices — Project Guide
## For Entry-Level DevOps Engineers

---

## WHAT IS THIS PROJECT?

This is a **veterinary clinic management system** — think of it as software that a real animal clinic would use to:
- Keep records of pet owners
- Track the animals (pets) they own
- Schedule and record vet visits
- Manage the list of veterinarians and their specialties

The app itself already exists and works. **Your job as a team is not to build the app — your job is to deploy it to the cloud (AWS) so that anyone in the world can access it via a web browser.**

---

## WHY IS IT CALLED "MICROSERVICES"?

Instead of being one giant program, this app is split into **small, independent programs (microservices)** that each do one job:

| Service | What It Does | Port |
|---|---|---|
| `config-server` | Acts like a settings file for all other services | 8888 |
| `discovery-server` | A phonebook — helps services find each other | 8761 |
| `customers-service` | Stores owner + pet data | 8081 |
| `vets-service` | Stores vet + specialties data | 8083 |
| `visits-service` | Stores appointment/visit records | 8082 |
| `api-gateway` | The front door — routes web traffic to the right service | 8080 |
| `admin-server` | Dashboard to see health of all services | 9090 |
| `genai-service` | AI chatbot feature (optional) | 8084 |

**Think of it like a hospital:** the reception desk (api-gateway) receives you and sends you to the right department (customers, vets, visits). Each department has its own records (databases).

---

## WHAT DOES THE DEPLOYMENT LOOK LIKE?

```
User's Browser
      |
      v
  API Gateway  (single entry point - gets a public IP from AWS)
      |
   --------
   |      |
Customers Vets  Visits   (backend services)
   |      |      |
  DB1    DB2    DB3      (3 separate MySQL databases)
      |
 Config Server   (all services read their settings from here)
      |
 Discovery Server  (all services register here so they can find each other)
      |
 Prometheus + Grafana  (monitoring - shows charts of how the app is doing)
      |
 Zipkin  (tracing - shows the path of a single request through all services)
```

---

## WHERE IS IT BEING DEPLOYED?

**AWS EKS (Elastic Kubernetes Service)**

- **AWS** = Amazon Web Services — the cloud provider. You rent their servers.
- **EKS** = A managed Kubernetes service on AWS.
- **Kubernetes (K8s)** = A system that runs and manages your application containers on a cluster of servers.

**Simple analogy:**
- AWS = the building with all the computers
- EKS = the manager that organizes how those computers run programs
- Kubernetes = the instruction manual that tells the manager what to run and how

---

## KEY TECHNOLOGIES YOU WILL ENCOUNTER

| Technology | What It Is | Why It's Used |
|---|---|---|
| **Docker** | Packages an app and everything it needs into a container | Same as a shipping container — runs the same everywhere |
| **Kubernetes (kubectl)** | Orchestrates containers across multiple servers | Manages starting, stopping, scaling containers |
| **Helm** | Package manager for Kubernetes | Like npm/apt but for Kubernetes apps |
| **AWS ECR** | Container image storage on AWS | Where built Docker images are stored |
| **AWS EKS** | Kubernetes cluster on AWS | Where the app actually runs |
| **eksctl** | CLI tool to create EKS clusters | Makes EKS cluster creation easy |
| **GitHub Actions** | Automated CI/CD pipeline | Automatically builds + deploys code when pushed |
| **MySQL** | Relational database | Stores the app's data permanently |
| **Prometheus** | Collects metrics from services | Answers: "How much CPU is this using?" |
| **Grafana** | Shows Prometheus data as charts | Pretty dashboards for metrics |
| **Zipkin** | Distributed tracing | Tracks a single user request across all services |

---

## THE TEAM — 9 ROLES AND WHAT EACH PERSON DOES

### P1 — Scrum Master / Project Lead
Runs the team. Creates the GitHub organization, project board, facilitates daily standups, ensures nobody is blocked. Writes the final presentation.

### P2 — AWS Infrastructure Engineer
Creates and manages the actual AWS EKS Kubernetes cluster. Installs tools (kubectl, eksctl, helm), provisions nodes, and gives other team members cluster access.

### P3 — CI/CD Engineer
Sets up GitHub Actions — the automated pipeline that builds Docker images and pushes them to AWS ECR every time code is committed. Automates the deploy step too.

### P4 — Config & Discovery Owner
Deploys `config-server` and `discovery-server` to Kubernetes. These two services must start first because everything else depends on them.

### P5 — Backend Dev (Customers & Vets)
Writes Kubernetes manifest files to deploy `customers-service` and `vets-service` to EKS.

### P6 — Backend Dev (Visits & API Gateway)
Writes Kubernetes manifest files to deploy `visits-service` and `api-gateway` to EKS. The `api-gateway` gets a public-facing LoadBalancer so the outside world can access the app.

### P7 — Database Administrator (YOUR ROLE)
Deploys 3 separate MySQL databases (one for each backend service) to Kubernetes using Helm. Creates the credentials (secrets), configures each database, and verifies the data is loaded correctly.

### P8 — Observability Engineer
Deploys Prometheus, Grafana, and Zipkin to EKS. Sets up the monitoring dashboards so the team can see live metrics.

### P9 — QA & Demo Lead
Tests the entire deployed application end-to-end. Writes the demo script. Leads the final live presentation demo.

---

## WHAT IS REQUIRED TO BRING THIS PROJECT TO LIFE?

### From a high level, in order:

1. **GitHub organization + repo** (P1) — Team's shared code home
2. **AWS account** with EKS cluster (P2) — The cloud infrastructure to run on
3. **CI/CD pipeline** (P3) — Automates building and pushing Docker images
4. **Config + Discovery servers deployed** (P4) — Foundation that all services depend on
5. **Databases deployed** (P7) — Data storage ready before backend services start
6. **Backend services deployed** (P5, P6) — The actual application logic
7. **Monitoring deployed** (P8) — Visibility into the running system
8. **Testing + Demo** (P9) — Prove it all works

### The dependency chain matters:
```
EKS Cluster (P2)
    → Databases (P7)
        → Config + Discovery (P4)
            → Backend Services (P5, P6)
                → Monitoring (P8)
                    → Testing (P9)
```

---

## WHAT YOU NEED TO HAVE (Tools & Accounts)

### Required Accounts:
- [ ] GitHub account (free)
- [ ] AWS account (free tier works for this project)

### Required Software to Install (on your computer):
- [ ] **Git** — version control (`git --version` to check)
- [ ] **Docker Desktop** — to build and test containers locally
- [ ] **AWS CLI** — to talk to AWS from the terminal
- [ ] **kubectl** — to talk to Kubernetes
- [ ] **Helm** — Kubernetes package manager
- [ ] **eksctl** — to create EKS clusters

### Required Information (get from your team):
- AWS Account ID (12-digit number)
- AWS region being used (us-east-1)
- EKS cluster name (petclinic-cluster)
- The team's GitHub organization URL

---

## YOUR ROLE IN DETAIL: P7 — DATABASE ADMINISTRATOR

### What you are responsible for:
You are deploying **3 MySQL databases** — one for each backend service. Each database is completely isolated from the others (this is the microservices pattern).

| Database Name (in K8s) | Used by Service | Tables |
|---|---|---|
| `customers-db` | customers-service | `owners`, `pets`, `types` |
| `vets-db` | vets-service | `vets`, `specialties`, `vet_specialties` |
| `visits-db` | visits-service | `visits` |

### How the data gets into the database:
The Spring Boot application automatically runs `schema.sql` (creates tables) and `data.sql` (inserts sample data) when it starts up with the `mysql` profile active. You deploy the database — the app populates it.

### Your main deliverables:
1. A Kubernetes **Secret** named `petclinic-db-secret` (holds username + password)
2. Three Helm values files:
   - `k8s/mysql-customers-values.yaml`
   - `k8s/mysql-vets-values.yaml`
   - `k8s/mysql-visits-values.yaml`
3. Three deployed MySQL instances on EKS
4. Verified that all 3 databases are running and reachable
5. A 5-minute presentation showing your work

### Your files live in the `k8s/` directory of the repo.

---

## THE 7-DAY SCHEDULE (BIG PICTURE)

| Day | Focus | P7's Work |
|---|---|---|
| Day 1 (Mon) | Setup & Orientation | Clone repo, run locally, study schema files, add Helm repo |
| Day 2 (Tue) | Build & Plan | Write Helm values files, plan secrets |
| Day 3 (Wed) | Deploy Infrastructure | Create Kubernetes secret, deploy all 3 MySQL databases |
| Day 4 (Thu) | Deploy All Services | Verify databases have data, document connection strings |
| Day 5 (Fri) | Monitoring & Testing | Monitor DB health, assist backend team if DB issues arise |
| Day 6 (Sat) | Harden & Prepare | Prepare your 5-min demo, practice your CLI commands |
| Day 7 (Sun) | Presentation Day | Show your MySQL pods, secrets, and demo query output |

---

## GLOSSARY — KEY TERMS EXPLAINED SIMPLY

**Pod** — The smallest unit in Kubernetes. Think of it as a running container (one running instance of a program).

**Deployment** — A Kubernetes instruction that says "keep N copies of this pod running at all times."

**Service (K8s Service)** — A stable network address for a pod. Other pods use the Service name to talk to each other (not the pod's IP, which changes).

**Namespace** — A folder-like grouping in Kubernetes. All your app's resources live in the `spring-petclinic` namespace.

**Secret** — A Kubernetes object that stores sensitive data (passwords, API keys) securely rather than in plain text in config files.

**Helm Chart** — A pre-packaged Kubernetes application. The Bitnami MySQL chart is a pre-built, production-ready MySQL setup for Kubernetes. You just pass your settings (values).

**Helm Values File** — A YAML file where you configure what a Helm chart should install (database name, password, storage size, etc.).

**ECR (Elastic Container Registry)** — AWS's private Docker image storage. Like Docker Hub but private and inside AWS.

**LoadBalancer** — A Kubernetes Service type that tells AWS to create a public-facing load balancer (with a real internet IP/hostname) so the outside world can reach your app.

**ClusterIP** — A Kubernetes Service type that is only reachable from inside the cluster (used for internal services like databases).

**kubectl** — The command-line tool used to talk to a Kubernetes cluster. Every K8s command starts with `kubectl`.

**PersistentVolumeClaim (PVC)** — How a pod requests disk storage from Kubernetes. MySQL uses this to store data that survives pod restarts.

---

## COMMON TROUBLESHOOTING COMMANDS

```bash
# See all running pods in your namespace
kubectl get pods -n spring-petclinic

# See why a pod is failing
kubectl describe pod <pod-name> -n spring-petclinic

# See the logs from a pod
kubectl logs <pod-name> -n spring-petclinic

# See all services (and their IPs)
kubectl get svc -n spring-petclinic

# Restart a stuck deployment
kubectl rollout restart deployment/<name> -n spring-petclinic

# Get into a running pod's shell (for debugging)
kubectl exec -it <pod-name> -n spring-petclinic -- bash
```

---

## PROJECT REPO STRUCTURE

```
spring-petclinic-microservices/
├── spring-petclinic-config-server/        # Config server source code
├── spring-petclinic-discovery-server/     # Discovery (Eureka) server code
├── spring-petclinic-customers-service/    # Customers service code + DB schema
│   └── src/main/resources/db/mysql/
│       ├── schema.sql                     # Creates owners, pets, types tables
│       └── data.sql                       # Seeds sample data
├── spring-petclinic-vets-service/         # Vets service code + DB schema
│   └── src/main/resources/db/mysql/
│       ├── schema.sql                     # Creates vets, specialties tables
│       └── data.sql                       # Seeds sample vets
├── spring-petclinic-visits-service/       # Visits service code + DB schema
│   └── src/main/resources/db/mysql/
│       ├── schema.sql                     # Creates visits table
│       └── data.sql                       # Seeds sample visits
├── spring-petclinic-api-gateway/          # API gateway code
├── infra/                                 # Terraform files (AWS setup by P2)
├── k8s/                                   # Kubernetes manifests (YOUR FILES GO HERE)
├── docker-compose.yml                     # Runs entire app locally
├── role_instructions                      # The team playbook (all 9 roles, 7 days)
└── CLAUDE.md                              # This file
```

---

## IMPORTANT NOTES

1. **The `k8s/` directory is where you save your work.** Everything you create goes in there.

2. **Always work in the `spring-petclinic` namespace.** Add `-n spring-petclinic` to every kubectl command.

3. **P2 must create the EKS cluster first** before you can deploy anything. Coordinate with P2.

4. **Your databases must be running before P5/P6 deploy their services.** You are a dependency for the backend developers.

5. **The app seeds its own data.** You don't need to manually run SQL scripts — Spring Boot does it automatically on first startup.

6. **Delete the cluster after the demo** to avoid AWS charges. The EKS cluster costs money while running.
