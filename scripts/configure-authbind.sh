#! /bin/bash

# Access our Catalina variables
source /etc/profile.d/tomcat.sh

# Have Tomcat listen on the configured ports (instead of on 8080 and 8443)
echo "AUTHBIND=yes" | sudo tee -a /etc/default/$CATALINA_VERSION > /dev/null
sudo touch /etc/authbind/byport/$TOMCAT_PORT
sudo chmod 500 /etc/authbind/byport/$TOMCAT_PORT
sudo chown $CATALINA_USER /etc/authbind/byport/$TOMCAT_PORT
sudo sed -i "s/port\=\"8080\"/port\=\"$TOMCAT_PORT\"/" $CATALINA_CONFIGS/server.xml
sudo touch /etc/authbind/byport/$TOMCAT_SSH_PORT
sudo chmod 500 /etc/authbind/byport/$TOMCAT_SSH_PORT
sudo chown $CATALINA_USER /etc/authbind/byport/$TOMCAT_SSH_PORT
sudo sed -i "s/port\=\"8443\"/port\=\"$TOMCAT_SSH_PORT\"/" $CATALINA_CONFIGS/server.xml