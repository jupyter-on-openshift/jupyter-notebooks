#!/bin/bash

set -eo pipefail

if [[ ! -z "${JUPYTERHUB_API_TOKEN}" ]]; then
    exec /opt/app-root/bin/start-singleuser.sh "$@"
else
    if [[ ! -z "${JUPYTER_ENABLE_KERNELGATEWAY}" ]]; then
        . /opt/app-root/bin/start.sh jupyter kernelgateway \
            --config=/opt/app-root/etc/jupyter_kernel_gateway_config.py "$@"
    else
        if [[ ! -z "${JUPYTER_ENABLE_LAB}" ]]; then
            . /opt/app-root/bin/start.sh jupyter lab \
                --config=/opt/app-root/etc/jupyter_notebook_config.py "$@"
        else
            . /opt/app-root/bin/start.sh jupyter notebook \
                --config=/opt/app-root/etc/jupyter_notebook_config.py "$@"
        fi
    fi
fi
