#!/bin/bash

# Ensure we are running as root
if [ "$EUID" -ne 0 ]
 then echo "Please run as root"
 exit 1
fi

# Remove all snap packages
for PACKAGE in $(snap list --color=never --unicode=never | tail -n +2 | sed 's/ .*//' | grep -v '^snapd$' | grep -v '^bare$'| grep -v -E '^core[0-9]+$'); do
  # echo $PACKAGE
  snap remove $PACKAGE
done
snap remove bare
snap remove $(snap list --color=never --unicode=never | tail -n +2 | sed 's/ .*//' | grep -E '^core[0-9]+$')
snap remove snapd

# Remove it via apt
apt remove --purge --autoremove -y snapd

# Make sure it is never re-installed
apt-mark hold snapd

# Add firefox repo
add-apt-repository -y ppa:mozillateam/ppa
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | tee /etc/apt/preferences.d/mozilla-firefox

# Need to find out about firefox
apt update

# Re-install gnome and firefox
apt install -y gnome-software firefox
