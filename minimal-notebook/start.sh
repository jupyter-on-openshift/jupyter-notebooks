#!/bin/bash

set -eo pipefail

if [ $# -eq 0 ]; then
    echo "Executing the command: bash"
    exec bash
else
    echo "Executing the command: $@"
    exec "$@"
fi
