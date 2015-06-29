#! /bin/bash

# Define where we're putting Tomcat stuff
TOMCAT_VERSION="tomcat7"
TOMCAT_CONFIG_DIR="/etc/$TOMCAT_VERSION"
TOMCAT_HOME="/var/lib/$TOMCAT_VERSION"
TOMCAT_LOGS="/var/log/$TOMCAT_VERSION"
TOMCAT_USER="$TOMCAT_VERSION"

# This should fail when JDK 7 is end-of-life'd ... I think(?)
sudo apt-get install -y $TOMCAT_VERSION

# Set some environmental variables related to Tomcat and Java
echo "export CATALINA_HOME=$TOMCAT_HOME" | sudo tee -a /etc/profile.d/tomcat.sh > /dev/null
echo "export CATALINA_USER=$TOMCAT_USER" | sudo tee -a /etc/profile.d/tomcat.sh > /dev/null
echo "export CATALINA_VERSION=$TOMCAT_VERSION" | sudo tee -a /etc/profile.d/tomcat.sh > /dev/null
echo "export CATALINA_CONFIGS=$TOMCAT_CONFIG_DIR" | sudo tee -a /etc/profile.d/tomcat.sh > /dev/null
echo "export CATALINA_TMPDIR=/tmp" | sudo tee -a /etc/profile.d/tomcat.sh > /dev/null

# Create our keystore for Tomcat so it can support HTTPS connections [TODO: support passing these in via file provisioner]
KEYSTORE="$TOMCAT_CONFIG_DIR/keystore"
sudo keytool -genkey -noprompt -alias tomcat -dname "$KEYSTORE_CONFIG" -keyalg RSA -keystore "$KEYSTORE" \
  -storepass "$KEYSTORE_PASSWORD" -keypass "$KEYSTORE_PASSWORD"

# Configure Tomcat's JAVA_OPTS to reference our newly created keystore
JAVA_OPTS_CONFIG="-Xms$JVM_MEMORY -Xmx$JVM_MEMORY -XX:MaxPermSize=$JVM_MAX_PERM_SIZE"
JAVA_OPTS_CONFIG="$JAVA_OPTS_CONFIG -Djavax.net.ssl.trustStore=$KEYSTORE"
JAVA_OPTS_CONFIG="$JAVA_OPTS_CONFIG -Djavax.net.ssl.trustStorePassword=$KEYSTORE_PASSWORD"
# We use a different sed delimiter because slashes may occur in our KEYSTORE or KEYSTORE_PASSWORD variables
sudo sed -i -e "s|^JAVA_OPTS.*|JAVA_OPTS=\"$JAVA_OPTS_CONFIG\"|" /etc/default/$TOMCAT_VERSION

# Configure Tomcat's HTTPS Connector; the tilde is a little trick to insert a line feed to the XML file after we're done
SSL_CONNECTOR="~    <Connector minSpareThreads=\"25\" acceptCount=\"100\" scheme=\"https\" secure=\"true\""
SSL_CONNECTOR="$SSL_CONNECTOR SSLEnabled=\"true\" port=\"8443\" enableLookups=\"true\""
SSL_CONNECTOR="$SSL_CONNECTOR keystoreFile=\"$KEYSTORE\" keystorePass=\"$KEYSTORE_PASSWORD\""
SSL_CONNECTOR="$SSL_CONNECTOR URIEncoding=\"UTF-8\"\/>~  <\/Service>"
# We use a different sed delimiter because slashes may occur in our KEYSTORE or KEYSTORE_PASSWORD variables
sudo sed -i -e "s|  </Service>|$SSL_CONNECTOR|" $TOMCAT_CONFIG_DIR/server.xml

# Add a line feed in place of the tilde in the string above to put the Connector's configuration on a new line
tr '~' '\n' < $TOMCAT_CONFIG_DIR/server.xml | sudo tee $TOMCAT_CONFIG_DIR/server.xml > /dev/null

# Add these symlinks so Tomcat won't warn in the logs about them being missing
sudo ln -s $TOMCAT_HOME/shared /usr/share/$TOMCAT_VERSION/shared
sudo ln -s $TOMCAT_HOME/server /usr/share/$TOMCAT_VERSION/server
sudo ln -s $TOMCAT_HOME/common /usr/share/$TOMCAT_VERSION/common

# We're going to use pre-configured log files instead of the system.out dump that goes to catalina.out
sudo rm -rf $TOMCAT_LOGS/catalina.out
