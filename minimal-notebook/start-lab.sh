#!/bin/bash

set -eo pipefail

. /opt/app-root/bin/start.sh jupyter lab \
    --config=/opt/app-root/etc/jupyter_notebook_config.py "$@"
