# Quick Start: Docker Images for Spring PetClinic

## ✅ All 8 Services Ready to Deploy

### Image List & Sizes

```
springcommunity/spring-petclinic-config-server:4.0.1          454 MB
springcommunity/spring-petclinic-discovery-server:4.0.1       488 MB
springcommunity/spring-petclinic-api-gateway:4.0.1            522 MB
springcommunity/spring-petclinic-admin-server:4.0.1           507 MB
springcommunity/spring-petclinic-customers-service:4.0.1      550 MB
springcommunity/spring-petclinic-vets-service:4.0.1           552 MB
springcommunity/spring-petclinic-visits-service:4.0.1         550 MB
springcommunity/spring-petclinic-genai-service:4.0.1          608 MB
```

## Quick Commands

### Build All Images

```bash
./mvnw.cmd clean package -DskipTests
cd spring-petclinic-config-server && docker build -t springcommunity/spring-petclinic-config-server:4.0.1 . && cd ..
cd spring-petclinic-discovery-server && docker build -t springcommunity/spring-petclinic-discovery-server:4.0.1 . && cd ..
cd spring-petclinic-api-gateway && docker build -t springcommunity/spring-petclinic-api-gateway:4.0.1 . && cd ..
cd spring-petclinic-admin-server && docker build -t springcommunity/spring-petclinic-admin-server:4.0.1 . && cd ..
cd spring-petclinic-customers-service && docker build -t springcommunity/spring-petclinic-customers-service:4.0.1 . && cd ..
cd spring-petclinic-vets-service && docker build -t springcommunity/spring-petclinic-vets-service:4.0.1 . && cd ..
cd spring-petclinic-visits-service && docker build -t springcommunity/spring-petclinic-visits-service:4.0.1 . && cd ..
cd spring-petclinic-genai-service && docker build -t springcommunity/spring-petclinic-genai-service:4.0.1 . && cd ..
```

### Verify All Images

```bash
docker images springcommunity/* --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

### Test Individual Service

```bash
docker run -d --name config-server -p 8888:8888 springcommunity/spring-petclinic-config-server:4.0.1
docker ps  # Check "healthy" status
docker logs config-server
docker stop config-server
```

### Push to ECR

```bash
# Login first
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Tag and push each service
docker tag springcommunity/spring-petclinic-config-server:4.0.1 <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/spring-petclinic-config-server:4.0.1
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/spring-petclinic-config-server:4.0.1
# ... repeat for all 8 services
```

## Service Ports

| Service           | Port | Purpose                    |
| ----------------- | ---- | -------------------------- |
| config-server     | 8888 | Configuration management   |
| discovery-server  | 8761 | Service discovery (Eureka) |
| api-gateway       | 8080 | API Gateway & Frontend     |
| admin-server      | 9090 | Spring Boot Admin          |
| customers-service | 8081 | Customer management        |
| vets-service      | 8082 | Veterinarian management    |
| visits-service    | 8083 | Pet visit records          |
| genai-service     | 8081 | AI features                |

## Key Features

✅ **Multi-stage builds** - Builder stage extracts JAR layers, runtime stage contains only JRE  
✅ **Java 17 LTS** - eclipse-temurin:17-jre-jammy base image  
✅ **Non-root user** - Runs as `springboot` user (UID 10001) for security  
✅ **Health checks** - HEALTHCHECK configured with 30s interval  
✅ **Proper entry point** - JarLauncher for optimal startup  
✅ **Optimized sizes** - 454MB-608MB (JRE only, no build tools)  
✅ **Spring profiles** - docker profile active in containers

## Documentation

- `DOCKERFILE_DOCUMENTATION.md` - Comprehensive guide
- `SPC-005-T7-COMPLETION-REPORT.md` - Detailed completion report

## Status

✅ All 8 Docker images successfully built and tested  
✅ All images running locally with "healthy" status  
✅ Ready for ECR push and Kubernetes deployment
