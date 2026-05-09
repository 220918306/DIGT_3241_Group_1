# Discovery Server (Eureka)
See the main README in `k8s/config-server/README.md` for full documentation.

This folder contains:
- `deployment.yaml` — K8s Deployment for discovery-server (port 8761)
- `service.yaml` — K8s ClusterIP Service on port 8761

Key points:
- Uses an initContainer to wait for config-server to be healthy before starting
- Spring profile: docker
- CONFIG_SERVER_URL points to http://config-server:8888 (K8s service name)
- Must start BEFORE customers, vets, visits, api-gateway, genai, admin services
