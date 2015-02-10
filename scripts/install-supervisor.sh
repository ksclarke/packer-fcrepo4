#! /bin/bash

# Install Supervisor
sudo apt-get install -y supervisor

# Install our special sauce Tomcat startup script
TOMCAT_SCRIPT="/usr/local/sbin/run-tomcat-in-docker.sh"
sudo cp /tmp/run-tomcat-in-docker.sh $TOMCAT_SCRIPT
sudo chown tomcat7:tomcat7 $TOMCAT_SCRIPT
sudo chmod 770 $TOMCAT_SCRIPT

# Install Supervisor's configuration file
sudo tee /etc/supervisor/supervisord.conf > /dev/null <<SUPERVISOR_CONFIG_EOF

[unix_http_server]
file=/var/run/supervisor.sock
chmod=0700

[supervisord]
nodaemon=true
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid
childlogdir=/var/log/supervisor

[rpcinterface:supervisor]
supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock

[include]
files=/etc/supervisor/conf.d/*.conf

[program:tomcat]
user=tomcat7
command=$TOMCAT_SCRIPT
autostart=true
autorestart=true

SUPERVISOR_CONFIG_EOF
