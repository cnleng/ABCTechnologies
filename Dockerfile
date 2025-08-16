# ===== Stage 1: Build with Maven =====
FROM maven:3.9.9-eclipse-temurin-8 AS build

# Set working directory
WORKDIR /app

# Copy Maven descriptor first for dependency caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the rest of the source code
COPY src ./src

# Build WAR file (skip tests for faster build)
RUN mvn clean package -DskipTests

# ===== Stage 2: Runtime with Tomcat =====
FROM tomcat:8.5-jdk8-temurin-jammy

# Remove default ROOT application
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy WAR from the build stage into Tomcat's webapps directory
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]

