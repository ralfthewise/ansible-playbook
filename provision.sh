#!/bin/bash

ROOT="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "${ROOT}" &> /dev/null

#first make sure ansible is installed
./install_ansible.sh

#configure what will be installed via ansible
ANSIBLE_HOST="localhost"
ANSIBLE_GROUPS="localhost,vim"
export ANSIBLE_HOST ANSIBLE_GROUPS

#fucking do this shit, bitch!!
ansible-playbook site.yml -vv -i dynamic.py --ask-become-pass "$@"

popd &> /dev/null
