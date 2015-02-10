#! /bin/bash

sudo apt-get install -y unzip git maven

# Pull in information about our Tomcat installation
source /etc/profile.d/tomcat.sh

# Configure the location of the metrics server from user supplied Packer variable
echo "export METRICS_SERVER=$GRAPHITE_SERVER" | sudo tee -a /etc/profile.d/fedora.sh > /dev/null

# Install a script to check to see if the metrics server is accessible
METRICS_SERVER_SCRIPT="/usr/local/sbin/fedora-metrics-server"
sudo cp /tmp/fedora-metrics-server.sh $METRICS_SERVER_SCRIPT
sudo chown root:root $METRICS_SERVER_SCRIPT
sudo chmod 700 $METRICS_SERVER_SCRIPT

# Install Fedora from the GitHub repository
if hash git 2>/dev/null; then
  sudo mkdir /opt/fcrepo4
  sudo chown -R `whoami`:$CATALINA_USER /opt/fcrepo4

  # Go ahead and download Fedora from the GitHub repository
  cd /opt/fcrepo4
  git clone https://github.com/fcrepo4/fcrepo4.git .

  # Check to see whether we want a development or stable version; we'll be less cautious with stable version
  if [[ "$FEDORA_VERSION" != *"x"* ]]; then
    # If running a stable version, it's okay to leave the HEAD detached -- we'll update by using a new container
    git checkout tags/fcrepo-$FEDORA_VERSION

    # If we're using stable version, the tests should be okay to skip
    TEST_FLAG="-DskipTests=true"
  fi

  MAVEN_OPTS="-Xmx$JVM_MEMORY -XX:MaxPermSize=$JVM_MAX_PERM_SIZE" mvn $TEST_FLAG install

  # Create the fedora.home directory for the repository's data (this can be configured as a mounted partition)
  sudo mkdir /media/fcrepo4-data
  sudo chown $CATALINA_USER:$CATALINA_USER /media/fcrepo4-data

  # Update JAVA_OPTS to include our fedora.home configuration
  sudo sed -i -e "s|\-Xms|\-Dfcrepo\.home\=/media/fcrepo4\-data \`/usr/local/sbin/fedora-metrics-server\` \-Xms|" \
    /etc/default/$CATALINA_VERSION

  # Deploy the Fedora webapp that we built with the above Maven command
  sudo rm -rf $CATALINA_HOME/webapps/ROOT

  # Actually want to put this at ROOT but there seems to be a problem with this (I haven't figured out the solution yet)
  sudo unzip -d $CATALINA_HOME/webapps/fcrepo4 "fcrepo-webapp/target/fcrepo-webapp-$FEDORA_VERSION.war"
  sudo chown -R $CATALINA_USER:$CATALINA_USER $CATALINA_HOME/webapps/fcrepo4

  # TODO: some more configuration stuff... and things
else
  echo "Git must be installed to proceed"
  exit 1
fi