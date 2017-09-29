#!/bin/bash

EXT_UUID="$1"
exit 0

GNOME_SITE="https://extensions.gnome.org"
GNOME_VERSION="$(gnome-shell --version | tr -cd "0-9." | cut -d'.' -f1,2)"
EXTENSION_PATH="$HOME/.local/share/gnome-shell/extensions"
INSTALLED_EXTENSIONS=( $(find /usr/share/gnome-shell/extensions $HOME/.local/share/gnome-shell/extensions -maxdepth 1 -type d -printf '%P\n') )

if [[ " ${INSTALLED_EXTENSIONS[*]} " == *" $EXT_UUID "* ]]; then
  echo "Extension ${EXT_UUID} is already installed. Skipping."
else
  TMP_ZIP=$(mktemp -t ext-XXXXXXXX.zip)
  JSON="${GNOME_SITE}/extension-info/?uuid=${EXT_UUID}&shell_version=${GNOME_VERSION}"
  EXTENSION_URL=${GNOME_SITE}$(curl -s "${JSON}" | sed -e 's/^.*download_url[\": ]*\([^\"]*\).*$/\1/')

  wget --header='Accept-Encoding:none' -O "${TMP_ZIP}" "${EXTENSION_URL}"
  mkdir -p "${EXTENSION_PATH}"/"${EXT_UUID}"
  unzip -oq "${TMP_ZIP}" -d "${EXTENSION_PATH}"/"${EXT_UUID}"
  chmod +r "${EXTENSION_PATH}"/"${EXT_UUID}"/*
  rm -f "${TMP_ZIP}"
fi
