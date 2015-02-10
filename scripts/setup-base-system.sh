#! /bin/bash

# Start the basic system installation; put in a stupid loop to work around rare AWS-Ubuntu mirror issues
for ATTEMPT in 1 2 3; do
  sudo apt-get update -y --fix-missing
  sudo apt-get install -ym nano htop nmap wget unattended-upgrades

  if [ ! -z "`which nano`" ] && [ ! -z "`which htop`"  ] && [ ! -z "`which nmap`"  ] && [ ! -z "`which wget`"  ] \
      && [ ! -z "`which unattended-upgrade`" ]; then
    sudo unattended-upgrade
    break
  fi
done

if [ -z "`which nano`" ] || [ -z "`which htop`"  ] || [ -z "`which nmap`"  ] || [ -z "`which wget`"  ] \
    || [ -z "`which unattended-upgrade`" ]; then
  echo "We were not able to install all the basic system packages; probably an Ubuntu mirror issue(?)"
  exit 1
fi

# Give option to exclude commands that start with a space from Bash history (and ignore duplicate commands)
echo "export HISTCONTROL=ignoreboth" | sudo tee /etc/profile.d/packer_setup_config.sh >/dev/null
source /etc/profile.d/packer_setup_config.sh