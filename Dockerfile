FROM tomcat:latest
RUN cp -R  /usr/share/tomcat9/webapps.dist/*  /usr/local/tomcat/webapps
COPY /webapp/target/*.war /usr/share/tomcat9/webapps
