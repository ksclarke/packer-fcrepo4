#! /bin/bash

# If we're running in an environment where we can retrieve the metrics server location from user-data, get it that way
METRICS_SERVER=$(wget -T 5 -t 1 -q -O - http://169.254.169.254/latest/user-data)

# If we couldn't retrieve the metrics server from user-data, let's try the domain name that was configured in the build
if [ -z "$METRICS_SERVER" ]; then
  source /etc/profile.d/fedora.sh
fi

# Return the configuration needed to connect to the metrics server, but only if it's already up and running
if hash nc 2>/dev/null; then
  if [ $(nc -z -w 1 "$METRICS_SERVER" 2003; echo $?) == 0 ]; then
    echo "-Dspring.profiles.active=metrics.graphite -Dfcrepo.metrics.host=$METRICS_SERVER -Dfcrepo.metrics.port=2003"
  fi
fi