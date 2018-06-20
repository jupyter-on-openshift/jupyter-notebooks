#!/bin/bash

set -x

WEBDAV_PORT=${WEBDAV_PORT:-8081}

ARGS=""

ARGS="$ARGS --log-to-terminal"
ARGS="$ARGS --port $WEBDAV_PORT"
ARGS="$ARGS --application-type static"
ARGS="$ARGS --include /opt/app-root/etc/httpd-webdav.conf"

exec mod_wsgi-express start-server $ARGS
