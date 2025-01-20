#!/bin/bash

# Actualización de los paquetes disponibles
sudo apt update && sudo apt upgrade -y

# Instalación de OpenJDK 11, Tomcat 9 y Tomcat 9 Admin
sudo apt install -y openjdk-11-jdk tomcat9 tomcat9-admin

# Instalación de Maven
sudo apt-get update && sudo apt-get -y install maven

# Creación del grupo para Tomcat
sudo groupadd tomcat9 || true

# Creación del usuario para Tomcat
sudo useradd -s /bin/false -g tomcat9 -d /etc/tomcat9 tomcat9 || true

# Configuración de usuarios y permisos en Tomcat
sudo bash -c 'cat > /etc/tomcat9/tomcat-users.xml' <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
               version="1.0">
  <role rolename="admin"/>
  <role rolename="admin-gui"/>
  <role rolename="manager"/>
  <role rolename="manager-gui"/>
  <user username="alumno"
        password="1234"
        roles="admin,admin-gui,manager,manager-gui"/>
  <user username="deploy" password="1234" roles="manager-script"/>
</tomcat-users>
EOF

# Permitir acceso remoto al host-manager
sudo bash -c 'cat > /usr/share/tomcat9-admin/host-manager/META-INF/context.xml' <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" >
  <CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"
                   sameSiteCookies="strict" />
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="\\d+\\.\\d+\\.\\d+\\.\\d+" />
  <Manager sessionAttributeValueClassNameFilter="java\\.lang\\.(?
          :Boolean|Integer|Long|Number|String)|org\\.apache\\.catalina\\.filters\\.CsrfPreventionFilter\\
          $LruCache(?:\\$1)?|java\\.util\\.(?:Linked)?HashMap"/>
</Context>
EOF

# Configuración del archivo settings.xml para Maven
sudo bash -c 'cat > /etc/maven/settings.xml' <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <servers>
    <server>
      <id>Tomcat</id>
      <username>deploy</username>
      <password>1234</password>
    </server>
  </servers>
</settings>
EOF

# Reinicio del servicio Tomcat para aplicar cambios
sudo systemctl restart tomcat9

# Creación de un proyecto Maven
mvn archetype:generate -DgroupId=org.zaidinvergeles -DartifactId=tomcat-war -Ddeployment -DarchetypeArtifactId=maven-archetype-webapp -DinteractiveMode=false

# Entrar en el directorio del proyecto
cd tomcat-war

# Modificacion del archivo pom.xml
sudo bash -c 'cat > pom.xml' <<EOF
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>org.zaidinvergeles</groupId>
  <artifactId>tomcat-war</artifactId>
  <packaging>war</packaging>
  <version>1.0-SNAPSHOT</version>
  <name>tomcat-war Maven Webapp</name>
  <url>http://maven.apache.org</url>
  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>3.8.1</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
  <build>
    <finalName>tomcat-war</finalName>
	 <plugins>
	 <plugin>
	 <groupId>org.apache.tomcat.maven</groupId>
	 <artifactId>tomcat7-maven-plugin</artifactId>
	 <version>2.2</version>
	 <configuration>
	 <url>http://localhost:8080/manager/text</url>
	 <server>Tomcat</server>
	 <path>/despliegue</path>
	 </configuration>
	 </plugin>
 	</plugins>
  </build>
</project>
EOF

# Despliegue de la aplicacion
mvn tomcat7:deploy

# Volver a la carpeta raíz
cd 

# Instalación de Git
sudo apt update && sudo apt install -y git

# Clonar el repositorio de la aplicación
git clone https://github.com/cameronmcnz/rock-paper-scissors.git

# Entrar en el directorio de la aplicación
cd rock-paper-scissors

# Cambiar de rama
git checkout patch-1

# Modificacion del archivo pom.xml
sudo bash -c 'cat > pom.xml' <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.mcnz.rps.web</groupId>
  <artifactId>roshambo</artifactId>
  <version>1.0</version>
  <packaging>war</packaging>
  <name>roshambo web application</name>
  <url>http://www.mcnz.com</url>
  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <maven.compiler.source>1.7</maven.compiler.source>
    <maven.compiler.target>1.7</maven.compiler.target>
  </properties>
  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.11</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
  <build>
    <finalName>roshambo</finalName>
    <pluginManagement><!-- lock down plugins versions to avoid using Maven defaults (may be moved to parent pom) -->
       	<plugins>
        	<plugin>
            		<groupId>org.apache.tomcat.maven</groupId>
            		<artifactId>tomcat7-maven-plugin</artifactId>
            		<version>2.2</version>
            		<configuration>
                		<url>http://localhost:8080/manager/text</url>
                		<server>Tomcat</server>
                		<path>/rps</path>
            		</configuration>
        	</plugin>
   	 </plugins>
    </pluginManagement>
  </build>
</project>
EOF

# Despliegue de la aplicacion
mvn tomcat7:deploy

# Reinicio del servicio Tomcat para aplicar cambios
sudo systemctl restart tomcat9

# Comprobación del estado del servicio Tomcat
sudo systemctl enable tomcat9
sudo systemctl start tomcat9
sudo systemctl status tomcat9
