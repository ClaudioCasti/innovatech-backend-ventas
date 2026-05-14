# =============================================
# Dockerfile — Backend Ventas
# Spring Boot 3.4.4 | Java 17 | Maven
# Multi-stage build | Usuario no-root
# =============================================

# ── Stage 1: BUILD ───────────────────────────
FROM maven:3.9-eclipse-temurin-17-alpine AS builder

WORKDIR /app

COPY pom.xml .

RUN mvn dependency:go-offline -B

COPY src ./src

RUN mvn package -DskipTests -B

# ── Stage 2: PRODUCCIÓN ──────────────────────
FROM eclipse-temurin:17-jre-alpine AS production

RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /app/target/Springboot-API-REST-0.0.1-SNAPSHOT.jar app.jar

RUN chown appuser:appgroup app.jar

USER appuser

EXPOSE 8080

ENV DB_ENDPOINT=localhost
ENV DB_PORT=3306
ENV DB_NAME=innovatech_db
ENV DB_USERNAME=root
ENV DB_PASSWORD=root

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]