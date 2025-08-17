FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy Maven wrapper and pom.xml for dependency resolution
COPY pom.xml ./
COPY .mvn .mvn
COPY mvnw ./

# Download dependencies
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

# Copy source code
COPY src src

# Build the application
RUN ./mvnw clean package -DskipTests -B

# Expose port
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "target/cron-parser-api-1.0.0.jar"]