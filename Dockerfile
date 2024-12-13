# Use a base image with OpenJDK 17
FROM openjdk:17-jdk-slim

# Install Maven
RUN apt-get update && \
    apt-get install -y maven && \
    apt-get clean

# Set the working directory
WORKDIR /app

# Copy the entire project
COPY . .

# Create a simple Java web server using Maven
RUN echo ' \
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" \
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd"> \
    <modelVersion>4.0.0</modelVersion> \
    <groupId>com.example</groupId> \
    <artifactId>hello-world</artifactId> \
    <version>1.0-SNAPSHOT</version> \
    <build> \
        <plugins> \
            <plugin> \
                <groupId>org.apache.maven.plugins</groupId> \
                <artifactId>maven-compiler-plugin</artifactId> \
                <version>3.8.1</version> \
                <configuration> \
                    <source>17</source> \
                    <target>17</target> \
                </configuration> \
            </plugin> \
        </plugins> \
    </build> \
</project>' > pom.xml

RUN echo ' \
import com.sun.net.httpserver.HttpServer; \
import com.sun.net.httpserver.HttpHandler; \
import com.sun.net.httpserver.HttpExchange; \
import java.io.OutputStream; \
import java.net.InetSocketAddress; \
public class App { \
    public static void main(String[] args) throws Exception { \
        HttpServer server = HttpServer.create(new InetSocketAddress(8090), 0); \
        server.createContext("/", new HttpHandler() { \
            public void handle(HttpExchange exchange) throws java.io.IOException { \
                String response = "Hello, World!"; \
                exchange.sendResponseHeaders(200, response.length()); \
                OutputStream os = exchange.getResponseBody(); \
                os.write(response.getBytes()); \
                os.close(); \
            } \
        }); \
        server.start(); \
        System.out.println("Server is running on http://localhost:8090"); \
    } \
}' > src/main/java/App.java

# Build the project
RUN mvn compile assembly:single

# Expose the port
EXPOSE 8090

# Command to run the JAR file
ENTRYPOINT ["java", "-cp", "target/hello-world-1.0-SNAPSHOT-jar-with-dependencies.jar", "App"]
