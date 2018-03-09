#!/bin/bash

SRC=$1
DEST=$2

if [ -f $DEST/.delete-volume]; then
    rm -rf $DEST
fi

if [ -e $DEST ]; then
   exit
fi

rsync --archive --no-perms $SRC/ $DEST
