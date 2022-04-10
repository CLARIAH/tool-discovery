#!/bin/sh

# this script is typically invoked periodically from cron


die() {
    echo "$@" >&2
    exit 1
}


CSS="$BASEURI/resources/codemeta.css,$BASEURI/resources/fontawesome.css"
if [ -n "$1" ]; then
    BASEURI="$1"
    HARVEST_OPTS="--baseuri $1"
    CODEMETAPY_OPTS="--baseuri $1 --toolstore --css $CSS"
else
    HARVEST_OPTS=""
    CODEMETAPY_OPTS="--toolstore --css $CSS"
fi

CONFIGURL="$2"
[ -n "$CONFIGURL" ] || die "No configuration URL provided (expected a git repository)"
CONFIGPATH="$3"

# Update the source registry containing the configuration for codemeta-harvester

mkdir -p /usr/src/
if [ ! -d /usr/src/source-registry ]; then
    echo "Cloning configuration repository $CONFIGURL"
    cd /usr/src
    git clone "$CONFIGURL" source-registry || die "Unable to clone source registry"
    cd -
else
    echo "Updating configuration repository $CONFIGURL"
    cd /usr/src/source-registry
    git pull || die "Unable to update source registry"
    cd -
fi

#prepare temporary output directory
rm -rf /tmp/out || true
mkdir -p /tmp/out


#Run the harvester
echo "Invoking harvester: codemeta-harvester $HARVEST_OPTS --opts \"$CODEMETAPY_OPTS\" --outputdir /tmp/out /usr/src/source-registry/$CONFIGPATH" >&2
if codemeta-harvester $HARVEST_OPTS --opts "$CODEMETAPY_OPTS" --outputdir /tmp/out "/usr/src/source-registry/$CONFIGPATH" 2>&1 | tee /tmp/out/harvest.log; then
    #Creating joined graph
    echo "Creating joined graph (json)">&2
    codemetapy $CODEMETAPY_OPTS --graph /tmp/out/*.codemeta.json > /tmp/out/data.json || die "failed to create joined graph"

    echo "Syncing temporary output to target dir">&2
    rsync --exclude 'archive' --delete -av /tmp/out/ /tool-store-data/ || die "failed to rsync"

    echo "Stopping the Tool Store API (will automatically restart)">&2
    killall uvicorn

    rm -Rf /tmp/out #cleanup
fi

