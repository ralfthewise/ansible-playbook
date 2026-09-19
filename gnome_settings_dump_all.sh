#!/bin/bash

TS=$(date +"%Y%m%d-%H%M%S")

SETTINGS_DIR=~/Documents/ubuntu_settings_dump
mkdir -p $SETTINGS_DIR

# Gnome 3 can be customised from the command line via the gsettings command
# This script should help you to find what you're looking for by
# listing the ranges for all keys for each schema
GSETTINGS_FILE=$([ -f $SETTINGS_DIR/gsettings-vanilla.dump ] && echo $SETTINGS_DIR/gsettings-$TS.dump || echo $SETTINGS_DIR/gsettings-vanilla.dump)
for schema in $(gsettings list-schemas | sort)
do
  for key in $(gsettings list-keys $schema | sort)
  do
    value="$(gsettings get $schema $key | tr "\n" " ")"
    echo "$schema :: $key :: $value" >> $GSETTINGS_FILE
  done
done

# dconf sometimes has different info
DCONF_FILE=$([ -f $SETTINGS_DIR/dconf-vanilla.dump ] && echo $SETTINGS_DIR/dconf-$TS.dump || echo $SETTINGS_DIR/dconf-vanilla.dump)
dconf dump / >> $DCONF_FILE
