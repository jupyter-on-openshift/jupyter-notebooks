#!/bin/bash

set -x

set -eo pipefail

JUPYTER_ENABLE_LAB=`echo "$JUPYTER_ENABLE_LAB" | tr '[A-Z]' '[a-z]'`

if [[ ! -z "${JUPYTERHUB_API_TOKEN}" ]]; then
    exec /opt/app-root/bin/start-singleuser.sh "$@"
else
    if [[ ! -z "${JUPYTER_ENABLE_KERNELGATEWAY}" ]]; then
        exec /opt/app-root/bin/start-kernelgateway.sh "$@"
    else
        if [[ "$JUPYTER_ENABLE_LAB" =~ ^(true|yes|y|1)$ ]]; then
            exec /opt/app-root/bin/start-lab.sh "$@"
        fi
    fi
fi

if [ x"$JUPYTER_MASTER_FILES" != x"" ]; then
    if [ x"$JUPYTER_WORKSPACE_NAME" != x"" ]; then
        JUPYTER_WORKSPACE_PATH=/opt/app-root/src/$JUPYTER_WORKSPACE_NAME
        setup-volume.sh $JUPYTER_MASTER_FILES $JUPYTER_WORKSPACE_PATH
    fi
fi

if ! [[ "$JUPYTER_ENABLE_LAB" =~ ^(true|yes|y|1)$ ]]; then
    if [ x"$JUPYTER_WORKSPACE_NAME" != x"" ]; then
        JUPYTER_PROGRAM_ARGS="$JUPYTER_PROGRAM_ARGS --NotebookApp.default_url=/tree/$JUPYTER_WORKSPACE_NAME"
    fi
fi

JUPYTER_PROGRAM_ARGS="$JUPYTER_PROGRAM_ARGS --config=/opt/app-root/etc/jupyter_notebook_config.py"

exec /opt/app-root/bin/start.sh jupyter notebook $JUPYTER_PROGRAM_ARGS "$@"
