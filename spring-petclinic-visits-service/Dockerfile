FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN addgroup -S petclinic && adduser -S petclinic -G petclinic
USER petclinic

COPY target/*.jar app.jar

EXPOSE 8082

ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]
