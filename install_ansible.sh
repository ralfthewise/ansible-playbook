#!/bin/bash

# This script installs ansible

if [ ! -f "/usr/bin/ansible" ]; then
  sudo apt-get -y -q install software-properties-common build-essential

  #would like to do this, but ansible often takes months to update PPA for new OS releases
  #sudo add-apt-repository ppa:ansible/ansible

  #instead you can do this, but even this doesn't work if ansible for a previous OS release
  #won't work for the current release
  #sudo add-apt-repository 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu wily main'
  #sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367

  #sudo apt-get update
  #sudo apt-get -y install ansible

  #as a last resort, pip to the rescue!
  sudo apt-get -y -q install python-pip python-setuptools libffi-dev libcurl4-openssl-dev libssl-dev
  sudo -i pip install --upgrade pip
  sudo -i pip install --upgrade ansible
fi
