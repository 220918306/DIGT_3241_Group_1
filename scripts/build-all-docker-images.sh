#!/usr/bin/env bash

set -euo pipefail

IMAGE_PREFIX="${IMAGE_PREFIX:-springcommunity}"
VERSION_TAG="${VERSION_TAG:-latest}"

services=(
  spring-petclinic-config-server
  spring-petclinic-discovery-server
  spring-petclinic-customers-service
  spring-petclinic-visits-service
  spring-petclinic-vets-service
  spring-petclinic-genai-service
  spring-petclinic-api-gateway
  spring-petclinic-admin-server
)

declare -A ports=(
  [spring-petclinic-config-server]=8888
  [spring-petclinic-discovery-server]=8761
  [spring-petclinic-customers-service]=8081
  [spring-petclinic-visits-service]=8082
  [spring-petclinic-vets-service]=8083
  [spring-petclinic-genai-service]=8084
  [spring-petclinic-api-gateway]=8080
  [spring-petclinic-admin-server]=9090
)

echo "Building all service JAR files..."
./mvnw clean package -DskipTests

echo "Building Docker images..."

for service in "${services[@]}"; do
  jar_path="$(find "$service/target" -maxdepth 1 -type f -name "*.jar" ! -name "*sources.jar" ! -name "*javadoc.jar" | head -n 1)"

  if [[ -z "$jar_path" ]]; then
    echo "ERROR: No JAR found for $service"
    exit 1
  fi

  artifact_name="$(basename "$jar_path" .jar)"
  image_name="${IMAGE_PREFIX}/${service}:${VERSION_TAG}"
  port="${ports[$service]}"

  echo "--------------------------------------"
  echo "Service:       $service"
  echo "JAR:           $jar_path"
  echo "Artifact name: $artifact_name"
  echo "Port:          $port"
  echo "Image:         $image_name"
  echo "--------------------------------------"

  docker build \
    -f docker/Dockerfile \
    --build-arg ARTIFACT_NAME="$artifact_name" \
    --build-arg EXPOSED_PORT="$port" \
    -t "$image_name" \
    "$service/target"
done

echo "All Docker images built successfully."
docker images | grep spring-petclinic || true
