#!/bin/bash
# run as sudo

cd /opt/tada
source /opt/tada/venv/bin/activate
/opt/tada/venv/bin/python3 setup.py install --force
installTadaTables
