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

# Create a simple Java application
RUN echo ' \
public class Main { \
    public static void main(String[] args) { \
        System.out.println("Starting server..."); \
        try (java.net.ServerSocket server = new java.net.ServerSocket(8090)) { \
            while (true) { \
                try (java.net.Socket client = server.accept(); \
                     java.io.PrintWriter out = new java.io.PrintWriter(client.getOutputStream(), true)) { \
                    out.println("HTTP/1.1 200 OK\\r\\nContent-Type: text/plain\\r\\n\\r\\nHello, World!"); \
                } \
            } \
        } catch (Exception e) { \
            e.printStackTrace(); \
        } \
    } \
}' > src/main/java/Main.java

# Create a minimal Maven POM file
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
            <plugin> \
                <groupId>org.apache.maven.plugins</groupId> \
                <artifactId>maven-assembly-plugin</artifactId> \
                <version>3.3.0</version> \
                <configuration> \
                    <archive> \
                        <manifest> \
                            <mainClass>Main</mainClass> \
                        </manifest> \
                    </archive> \
                    <descriptorRefs> \
                        <descriptorRef>jar-with-dependencies</descriptorRef> \
                    </descriptorRefs> \
                </configuration> \
            </plugin> \
        </plugins> \
    </build> \
</project>' > pom.xml

# Build the application
RUN mvn clean package

# Expose port 8090
EXPOSE 8090

# Command to run the application
CMD ["java", "-cp", "target/hello-world-1.0-SNAPSHOT-jar-with-dependencies.jar", "Main"]
