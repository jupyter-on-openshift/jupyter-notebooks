#!/bin/bash

set -x

set -eo pipefail

JUPYTER_PROGRAM_ARGS="$JUPYTER_PROGRAM_ARGS $NOTEBOOK_ARGS"

if [ x"$JUPYTER_MASTER_FILES" != x"" ]; then
    if [ x"$JUPYTER_WORKSPACE_NAME" != x"" ]; then
        JUPYTER_WORKSPACE_PATH=/opt/app-root/src/$JUPYTER_WORKSPACE_NAME
        setup-volume.sh $JUPYTER_MASTER_FILES $JUPYTER_WORKSPACE_PATH
    fi
fi

if [ -z "$JUPYTER_ENABLE_LAB" ]; then
    if [ x"$JUPYTER_WORKSPACE_NAME" != x"" ]; then
        JUPYTER_PROGRAM_ARGS="$JUPYTER_PROGRAM_ARGS --NotebookApp.default_url=/tree/$JUPYTER_WORKSPACE_NAME"
    fi
else
    JUPYTER_PROGRAM_ARGS="$JUPYTER_PROGRAM_ARGS --NotebookApp.default_url=/lab"
fi

if [[ "$JUPYTER_PROGRAM_ARGS $@" != *"--ip="* ]]; then
    JUPYTER_PROGRAM_ARGS="--ip=0.0.0.0 $JUPYTER_PROGRAM_ARGS"
fi

JUPYTER_PROGRAM_ARGS="$JUPYTER_PROGRAM_ARGS --config=/opt/app-root/etc/jupyter_notebook_config.py"

if [ ! -z "$JUPYTER_ENABLE_LAB" ]; then
    JUPYTER_PROGRAM="jupyter labhub"
else
    JUPYTER_PROGRAM="jupyterhub-singleuser"
fi

exec /opt/app-root/bin/start.sh $JUPYTER_PROGRAM $JUPYTER_PROGRAM_ARGS "$@"
