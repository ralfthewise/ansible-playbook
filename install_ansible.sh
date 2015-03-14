#!/bin/bash

# This script installs ansible

if [ ! -f "/usr/bin/ansible" ]; then
  sudo apt-get -y -q install software-properties-common

  #would like to do this, but ansible hasn't release a PPA for utopic yet
  #sudo add-apt-repository ppa:ansible/ansible

  #have to do this instead
  sudo add-apt-repository 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main'
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367

  sudo apt-get update
  sudo apt-get -y install ansible
fi
