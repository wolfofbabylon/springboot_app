FROM openjdk:11-jre-slim
WORKDIR /app
COPY target/myapp-0.0.1.jar myapp.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "myapp.jar"]
