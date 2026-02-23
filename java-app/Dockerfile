# Stage 1: Build the application
FROM maven:3.9-eclipse-temurin-17 as build
WORKDIR /app
COPY . .
RUN mvn clean package

# Stage 2: Run the application
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=build /app/target/devops-project-1.0-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
