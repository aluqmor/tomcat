#!/bin/bash

# Actualización de los paquetes disponibles
sudo apt update && sudo apt upgrade -y

# Instalación de OpenJDK 11
sudo apt install -y openjdk-11-jdk

# Instalación de Tomcat 9
sudo apt install -y tomcat9

# Instalación de Tomcat 9 Admin
sudo apt install -y tomcat9-admin

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

# Reinicio del servicio Tomcat para aplicar cambios
sudo systemctl restart tomcat9

# Comprobación del estado del servicio Tomcat
sudo systemctl enable tomcat9
sudo systemctl start tomcat9
sudo systemctl status tomcat9
