#!/bin/bash

set -eo pipefail

DASK_SCHEDULER_ADDRESS:${DASK_SCHEDULER_ADDRESS:-127.0.0.1:8786}

. /opt/app-root/bin/start.sh dask-worker $DASK_SCHEDULER_ADDRESS $DASK_WORKER_ARGS "$@"
