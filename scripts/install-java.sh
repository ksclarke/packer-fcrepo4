#! /bin/bash

# OpenJDK 8 is still not yet in trusty-backports so we'll have to use Oracle's JDK 8
sudo apt-get -y install software-properties-common
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get install oracle-java8-installer
sudo apt-get install oracle-java8-set-default

echo "export JAVA_HOME=$(readlink -f /usr/bin/javac | sed 's:bin/javac::')" | sudo tee -a /etc/profile.d/java.sh  > /dev/null