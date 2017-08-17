#!/bin/bash

if [ $# -ne 2 ] ; then
  echo "Usage: $0 <backup location> <remote ssh backup location>"
  echo ""
  echo "  ex: $0 /mnt/data/reinstall/tim.2 tim@192.168.10.134"
  exit 0
fi
BACKUP_DIR="$1"
BACKUP_DIR="$(dirname "$BACKUP_DIR")/$(basename "$BACKUP_DIR")/"
REMOTE_BACKUP="$2"

mkdir -p "$BACKUP_DIR"

ROOT="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${ROOT}"
rsync -av $0 ~/bin/reinstall_finish.sh "$BACKUP_DIR"

#home folder
printf "\n\e[32mProcessing home folder\e[0m\n"
cd
mkdir -p "$BACKUP_DIR/home"
rsync -av --delete .ansible.cfg .bash_history .bash_logout .bashrc .gconf .gitconfig .irb-history .local .profile .pry_history .psql_history .ssh .VirtualBox .vnc bin tmp blog Documents Pictures Music Videos "$BACKUP_DIR/home/"
rsync -av --delete --exclude .config/google-chrome .config "$BACKUP_DIR/home/"
dconf dump / > "$BACKUP_DIR/home/current-dconf.dump"

#/etc
printf "\n\e[32mProcessing /etc\e[0m\n"
sudo rsync -av --delete /etc/ "$BACKUP_DIR/etc"

#/root
printf "\n\e[32mProcessing /root\e[0m\n"
sudo mkdir -p "$BACKUP_DIR/root"
sudo rsync -av /root/.bash_history "$BACKUP_DIR/root"

#mdadm
printf "\n\e[32mProcessing mdadm\e[0m\n"
mkdir -p "$BACKUP_DIR/mdadm"
sudo mdadm --detail --scan > "$BACKUP_DIR/mdadm/mdadm_detail_scan"
sudo mdadm --detail /dev/md0 > "$BACKUP_DIR/mdadm/mdadm_detail_md0"
sudo cat /proc/mdstat > "$BACKUP_DIR/mdadm/mdstat"
cp /etc/fstab "$BACKUP_DIR/mdadm"
sudo chown -R $USER "$BACKUP_DIR/mdadm"
ssh $REMOTE_BACKUP "mkdir -p ~/tmp/reinstall"
rsync -av --delete "$BACKUP_DIR/mdadm" $REMOTE_BACKUP:~/tmp/reinstall/

##one offs
printf "\n\e[32mProcessing one offs\e[0m\n"

mkdir -p "$BACKUP_DIR/home/dev"
cd ~/dev
rsync -av git_tricks.txt doodlebug pg-renc "$BACKUP_DIR/home/dev"
cd -

mkdir -p "$BACKUP_DIR/home/dev/idexperts"
cd ~/dev/idexperts
rsync -av ansible.passwd ops-windows-dev radartools-aws-dev-2015 radartools-aws-dev.pem rdesktop.sh scp.sh ssh.sh "$BACKUP_DIR/home/dev/idexperts"
cd -

rsync -av ~/VirtualBox\ VMs "$BACKUP_DIR/home/"

printf "\n\e[31mDon't forget to examine ~/dev for things that need to be saved\e[0m\n"
