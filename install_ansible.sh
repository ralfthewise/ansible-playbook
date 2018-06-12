#!/bin/bash

# This script installs ansible
ROOT="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "${ROOT}" &> /dev/null

#as a last resort, pip to the rescue!
sudo apt-get -y -q install software-properties-common build-essential python-pip python-setuptools libffi-dev libcurl4-openssl-dev libssl-dev
sudo -i pip install --upgrade pip
[ -e venv ] || virtualenv venv
source venv/bin/activate && pip install -r requirements.txt
