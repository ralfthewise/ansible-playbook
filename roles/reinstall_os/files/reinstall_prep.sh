#!/bin/bash

set -E
set -o pipefail

if [ $# -ne 2 ] ; then
  echo "Usage: $0 <backup location> <remote ssh backup location>"
  echo ""
  echo "  ex: $0 /mnt/data/reinstall/tim.2 tim@192.168.10.134"
  exit 0
fi
BACKUP_DIR="$1"
BACKUP_DIR="$(dirname "$BACKUP_DIR")/$(basename "$BACKUP_DIR")/"
REMOTE_BACKUP="$2"

# grab our term codes for pretty printing
bold=$(tput bold)
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

run() {
  mkdir -p "$BACKUP_DIR"

  ROOT="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  cd "${ROOT}"
  rsync -av $0 ~/bin/reinstall_finish.sh "$BACKUP_DIR"

  #home folder
  printf "\n\e[32mProcessing home folder\e[0m\n"
  cd
  mkdir -p "$BACKUP_DIR/home"
  local BACKUP_ITEM
  for BACKUP_ITEM in .ansible.cfg .bash_history .bash_logout .bashrc .gconf .gitconfig .irb-history .local .profile .pry_history .psql_history .ssh .VirtualBox .vnc bin tmp blog Documents Pictures Music Videos; do
    [ -e "$BACKUP_ITEM" ] && rsync -av --delete "$BACKUP_ITEM" "$BACKUP_DIR/home/"
  done
  rsync -av --delete --exclude .config/google-chrome --exclude .config/radar-deploy .config "$BACKUP_DIR/home/"
  dconf dump / > "$BACKUP_DIR/home/current-dconf.dump"

  #/etc
  printf "\n\e[32mProcessing /etc\e[0m\n"
  sudo rsync -av --delete /etc/ "$BACKUP_DIR/etc"

  #/root
  printf "\n\e[32mProcessing /root\e[0m\n"
  sudo mkdir -p "$BACKUP_DIR/root"
  sudo rsync -av /root/.bash_history "$BACKUP_DIR/root"

  #mdadm
  if [ -x "$(command -v mdadm)" ]; then
    printf "\n\e[32mProcessing mdadm\e[0m\n"
    mkdir -p "$BACKUP_DIR/mdadm"
    sudo mdadm --detail --scan > "$BACKUP_DIR/mdadm/mdadm_detail_scan"
    sudo mdadm --detail /dev/md0 > "$BACKUP_DIR/mdadm/mdadm_detail_md0"
    sudo cat /proc/mdstat > "$BACKUP_DIR/mdadm/mdstat"
    cp /etc/fstab "$BACKUP_DIR/mdadm"
    sudo chown -R $USER "$BACKUP_DIR/mdadm"
    ssh $REMOTE_BACKUP "mkdir -p ~/tmp/reinstall/$BACKUP_DIR"
    rsync -av --delete "$BACKUP_DIR/mdadm" $REMOTE_BACKUP:"~/tmp/reinstall/$BACKUP_DIR"
  fi

  ##one offs
  printf "\n\e[32mProcessing one offs\e[0m\n"

  mkdir -p "$BACKUP_DIR/home/dev"
  dlg --visit-items --keep-tite --no-cancel --no-items --separate-output --checklist "What do you wish to sync in ~/dev?" 0 0 0 $(ls -p ~/dev | sed 's/$/ off/') | while read DEV_ITEM; do
    rsync -av --delete --exclude '*node_modules/' --exclude '*vendor/' --exclude '*venv/' ~/dev/"$DEV_ITEM" "$BACKUP_DIR/home/dev/$DEV_ITEM"
  done

  rsync -av ~/VirtualBox\ VMs "$BACKUP_DIR/home/"

  printf "\n${bold}Don't forget to save browser tabs${reset}\n"
}

dlg() {
  trap - ERR # dialog uses return code to communicate cancellation
  dialog "$@" 2>&1 >&101
  local STATUS=$?
  add_err_handler # re-add err handler

  if [ $STATUS -eq 1 ] || [ $STATUS -eq 255 ]; then
    echo "Dialog cancelled" >&101
    exit $STATUS
  fi
  return $STATUS
}

#the usual housekeeping
exec 101>&1 # point 101 at raw stdout
# halt on any error
HALT_STATUS=77 # magic exit code to cascade termination up through parent processes
handle_err() {
  local RETVAL=$?
  local LINE=$1
  [ $RETVAL -ne $HALT_STATUS ] || exit $HALT_STATUS
  echo "Error occurred at line $LINE: $BASH_COMMAND"
  exit $HALT_STATUS
}
add_err_handler() {
  trap 'handle_err $LINENO' ERR
}
add_err_handler

run
