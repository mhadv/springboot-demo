# Use a base image with OpenJDK 17
FROM openjdk:17-jdk-slim

# Install Maven
RUN apt-get update && \
    apt-get install -y maven && \
    apt-get clean

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . .

# Build the Spring Boot application using Maven
RUN mvn clean package -DskipTests

# Expose port 8090
EXPOSE 8090

# Command to run the Spring Boot application
CMD ["java", "-jar", "target/sendevops-0.0.1-SNAPSHOT.jar"]
