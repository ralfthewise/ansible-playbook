#!/bin/bash

# This script installs ansible
ROOT="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "${ROOT}" &> /dev/null

sudo apt -y install software-properties-common build-essential libffi-dev libcurl4-openssl-dev libssl-dev python3-dev
sudo apt -y install python3.8-venv || sudo apt install -y python3.6-venv
[ -e .venv ] || python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip wheel
pip install -r requirements.txt
