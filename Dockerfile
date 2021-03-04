# FROM openjdk:8-jre-alpine
# EXPOSE 8080
# ADD target/*.jar app.jar
# ENTRYPOINT [ "sh", "-c", "java -jar /app.jar" ]
FROM squad5
COPY target/AVNCommunication-1.0.war /usr/local/tomcat/webapps/AVNCommunication-1.0.war
RUN service tomcat8 start
