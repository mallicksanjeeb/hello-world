# Use OpenJDK 17 as the base image
FROM openjdk:17

# Set working directory
WORKDIR /app

# Copy the built JAR file into the container
COPY target/*.jar app.jar

# Expose the application port
EXPOSE 8080

# Run the Spring Boot app
ENTRYPOINT ["java", "-jar", "app.jar"]