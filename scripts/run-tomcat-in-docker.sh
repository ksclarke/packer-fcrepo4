#! /bin/bash

# Simple script which pulls in /etc/default Tomcat config and avoids the `tail -f` hack to keep `service tomcat` in the foreground

# This pulls in CATALINA_TMPDIR
source /etc/profile.d/tomcat.sh

# This pulls in JAVA_OPTS and then exports it to the environment that the last line in this script will run in
source /etc/default/$CATALINA_VERSION
export JAVA_OPTS

# We want to overwrite CATALINA_HOME though (and add CATALINA_BASE) when running catalina.sh directly
export CATALINA_BASE="/var/lib/$CATALINA_VERSION"
export CATALINA_HOME="/usr/share/$CATALINA_VERSION"

# And this fires Tomcat up...
authbind --deep /usr/share/$CATALINA_VERSION/bin/catalina.sh run