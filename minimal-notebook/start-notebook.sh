#!/bin/bash

set -eo pipefail

NOTEBOOK_ARGS="--config=/opt/app-root/etc/jupyter_notebook_config.py"

if [[ ! -z "${JUPYTERHUB_API_TOKEN}" ]]; then
    exec /opt/app-root/bin/start-singleuser.sh "$@"
else
    if [[ ! -z "${JUPYTER_ENABLE_KERNELGATEWAY}" ]]; then
        . /opt/app-root/bin/start.sh jupyter kernelgateway "$@"
    else
        if [[ ! -z "${JUPYTER_ENABLE_LAB}" ]]; then
            . /opt/app-root/bin/start.sh jupyter lab $NOTEBOOK_ARGS "$@"
        else
            . /opt/app-root/bin/start.sh jupyter notebook $NOTEBOOK_ARGS "$@"
        fi
    fi
fi
