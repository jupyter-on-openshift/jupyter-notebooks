#!/bin/bash

set -x

set -eo pipefail

SRC=$1
DEST=$2

if [ -f $DEST/.delete-volume ]; then
    rm -rf $DEST
fi

if [ -d $DEST ]; then
    exit
fi

if [ -d $DEST.setup-volume ]; then
    rm -rf $DEST.setup-volume
fi

mkdir -p $DEST.setup-volume

tar -C $SRC -cf - . | tar -C $DEST.setup-volume -xvf -

mv $DEST.setup-volume $DEST
