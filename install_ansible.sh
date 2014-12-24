#!/bin/bash

# This script installs ansible

if [ ! -f "/usr/bin/ansible" ]; then
  sudo apt-get -y -q install software-properties-common

  #would like to do this, but ansible hasn't release a PPA for utopic yet
  #sudo add-apt-repository ppa:ansible/ansible

  #have to do this instead
  sudo add-apt-repository 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main'

  sudo apt-get update
  sudo apt-get -y -q install ansible
fi
