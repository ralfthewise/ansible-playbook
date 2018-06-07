#!/bin/bash

if [ $# -ne 1 ] ; then
  echo "Usage: $0 <backup location>"
  echo ""
  echo "  ex: $0 /mnt/data/reinstall/tim.2"
  exit 0
fi
BACKUP_DIR="$1"
BACKUP_DIR="$(dirname "$BACKUP_DIR")/$(basename "$BACKUP_DIR")/"

BOLD=$(tput bold)
NORMAL=$(tput sgr0)

#home folder
printf "\n\e[32mProcessing home folder\e[0m\n"
cd "$BACKUP_DIR/home"
if [[ $(stat -c%s .bash_history) -ge $(stat -c%s ~/.bash_history) ]]; then
  rsync -av .bash_history ~/.bash_history
else
  echo "${BOLD}Skipping .bash_history because existing file is larger than the backup${NORMAL}"
fi

local BACKUP_ITEM
# files
for BACKUP_ITEM in .ansible.cfg .irb-history .pry_history .psql_history; do
  [ -e "$BACKUP_ITEM" ] && rsync -av "$BACKUP_ITEM" ~/
done
# directories
for BACKUP_ITEM in bin tmp blog Documents Pictures Music Videos .config/VirtualBox .config/remmina .local/share/remmina; do
  [ -e "$BACKUP_ITEM" ] && rsync -av "$BACKUP_ITEM/" ~/"$BACKUP_ITEM/"
done
cd -

##one offs
printf "\n\e[32mProcessing one offs\e[0m\n"

mkdir -p ~/dev
rsync -av "$BACKUP_DIR/home/dev/" ~/dev/

rsync -av "$BACKUP_DIR/home/VirtualBox VMs" ~/

printf "\n\e[31mThe location of VirtualBox settings may have changed (~/.VirtualBox -> ~/.config/VirtualBox) since this script was written, double check it!\e[0m\n"
