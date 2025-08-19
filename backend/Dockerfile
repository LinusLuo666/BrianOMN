# Multi-stage build for smaller final image
FROM maven:3.9-openjdk-17 AS builder

WORKDIR /app

# Copy pom.xml first for dependency caching
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline -B

# Copy source code
COPY src src

# Build the application
RUN mvn clean package -DskipTests -B

# Runtime stage
FROM openjdk:17-jre-slim

WORKDIR /app

# Copy the built jar from builder stage
COPY --from=builder /app/target/cron-parser-api-1.0.0.jar app.jar

# Expose port
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]