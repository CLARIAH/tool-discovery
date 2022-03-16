#!/bin/sh

# this script is typically invoked periodically from cron

if [ -n "$1" ]; then
    OPTS="--baseuri \"$1\""
else
    OPTS=""
fi

rm -rf /tmp/out || true
mkdir /tmp/out
codemeta-harvester $OPTS --outputdir /tmp/out && rsync --delete -av /tmp/out/ /tool-store-data/
