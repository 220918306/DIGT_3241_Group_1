# Multi-stage build for minimal image size
FROM eclipse-temurin:17-jre-jammy AS builder
WORKDIR /app
COPY target/spring-petclinic-api-gateway-*.jar application.jar
RUN java -Djarmode=layertools -jar application.jar extract


# Runtime stage - JRE only for smaller image
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Create non-root user for security (least-privilege principle)
RUN groupadd -r springboot && useradd -r -g springboot springboot

# Set exposed port
EXPOSE 8080

# Set Spring profile
ENV SPRING_PROFILES_ACTIVE=docker \
    SPRING_APPLICATION_NAME=api-gateway

# Copy application layers from builder stage with proper ownership
COPY --from=builder --chown=springboot:springboot /app/dependencies/ ./
COPY --from=builder --chown=springboot:springboot /app/spring-boot-loader/ ./
COPY --from=builder --chown=springboot:springboot /app/snapshot-dependencies/ ./
COPY --from=builder --chown=springboot:springboot /app/application/ ./

# Switch to non-root user
USER springboot

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD java -version

ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
