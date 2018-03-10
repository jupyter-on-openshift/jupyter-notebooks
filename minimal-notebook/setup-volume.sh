#!/bin/bash

set -x

set -eo pipefail

SRC=$1
DEST=$2

if [ -f $DEST/.delete-volume ]; then
    rm -f $DEST.copied-volume
    rm -rf $DEST
fi

if [ -f $DEST.copied-volume ]; then
   exit
fi

mkdir $DEST

tar -C $SRC -cf - . | tar -C $DEST -xvf -

touch $DEST.copied-volume
