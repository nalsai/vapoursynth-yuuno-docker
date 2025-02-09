#!/bin/bash

set -euo pipefail
set -o errexit
set -o errtrace

if [ -f $STARTUP_SCRIPT ]; then
    echo "Running startup file.";
    sh $STARTUP_SCRIPT;
fi

sudo jupyter labextension disable "@jupyterlab/apputils-extension:announcements"
sudo jupyter lab --notebook-dir=/yuuno --no-browser --ip=0.0.0.0 --ServerApp.token='' --ServerApp.password=''  --ServerApp.allow_remote_access=True --ServerApp.port=8888 --allow-root
