#!/bin/bash

set -eo pipefail

. /opt/app-root/bin/start.sh jupyter kernelgateway \
    --config=/opt/app-root/etc/jupyter_kernel_gateway_config.py "$@"
