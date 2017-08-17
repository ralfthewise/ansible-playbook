#!/bin/bash

if [ $# -ne 1 ] ; then
  echo "Usage: $0 <backup location>"
  echo ""
  echo "  ex: $0 /mnt/data/reinstall/tim.2"
  exit 0
fi
BACKUP_DIR="$1"
BACKUP_DIR="$(dirname "$BACKUP_DIR")/$(basename "$BACKUP_DIR")/"

mkdir -p "$BACKUP_DIR"

ROOT="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${ROOT}"
rsync -av $0 "$BACKUP_DIR"

#home folder
printf "\n\e[32mProcessing home folder\e[0m\n"
cd "$BACKUP_DIR/home"
rsync -av .ansible.cfg .bash_history .psql_history .ssh bin tmp Documents Pictures Music Videos ~/
rsync -av .config/VirtualBox/ ~/.config/VirtualBox/
cd -

##one offs
printf "\n\e[32mProcessing one offs\e[0m\n"

mkdir -p ~/dev
cd "$BACKUP_DIR/home/dev"
rsync -av git_tricks.txt doodlebug pg-renc ~/dev
cd -

mkdir -p ~/dev/idexperts
cd "$BACKUP_DIR/home/dev/idexperts"
rsync -av ansible.passwd ops-windows-dev radartools-aws-dev-2015 radartools-aws-dev.pem rdesktop.sh scp.sh ssh.sh ~/dev/idexperts
cd -

rsync -av "$BACKUP_DIR/home/VirtualBox VMs" ~/

printf "\n\e[31mThe location of VirtualBox settings may have changed (~/.VirtualBox -> ~/.config/VirtualBox) since this script was written, double check it!\e[0m\n"
