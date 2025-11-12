#!/bin/bash
# Can be run like this:
#   ./provision.sh --tags git,vim

ROOT="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "${ROOT}" &> /dev/null

#first make sure ansible is installed
./install_ansible.sh
source .venv/bin/activate

#configure what will be installed via ansible
ANSIBLE_HOST="localhost"
ANSIBLE_GROUPS="localhost,vim"
export ANSIBLE_HOST ANSIBLE_GROUPS

#fucking do this shit, bitch!!
ansible-playbook site.yml -vv -i hosts.yml --ask-become-pass "$@"

echo "The following startup applications will be launched upon next login: caffeine-indicator, xbindkeys"
echo "Install the system monitor (doing the manual installation) from https://github.com/mgalgs/gnome-shell-system-monitor-next-applet"
popd &> /dev/null
