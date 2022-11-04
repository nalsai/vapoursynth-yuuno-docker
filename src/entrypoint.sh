#!/bin/bash

set -euo pipefail
set -o errexit
set -o errtrace

if [ -f $STARTUP_SCRIPT ]; then
    echo "Running startup file.";
    sh $STARTUP_SCRIPT;
fi

#jupyter notebook --allow-root
/home/yuuno/.local/bin/jupyter lab --notebook-dir=/yuuno
