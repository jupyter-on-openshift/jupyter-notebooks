#!/bin/bash

set -eo pipefail

if [[ "$NOTEBOOK_ARGS $@" != *"--ip="* ]]; then
  NOTEBOOK_ARGS="--ip=0.0.0.0 $NOTEBOOK_ARGS"
fi

NOTEBOOK_ARGS="$NOTEBOOK_ARGS --config=/opt/app-root/configs/jupyter_notebook_config.py"

if [ ! -z "$JUPYTER_ENABLE_LAB" ]; then
  NOTEBOOK_BIN="jupyter labhub"
else
  NOTEBOOK_BIN="jupyterhub-singleuser"
fi

. /opt/app-root/bin/start.sh $NOTEBOOK_BIN $NOTEBOOK_ARGS "$@"
