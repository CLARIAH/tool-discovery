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
else
    HARVEST_OPTS=""
fi
CODEMETAPY_OPTS="--toolstore --css $CSS"

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
echo "Invoking harvester: codemeta-harvester $HARVEST_OPTS --opts \"$CODEMETAPY_OPTS\" --outputdir /tmp/out /usr/src/source-registry/$CONFIGPATH && rsync --delete -av /tmp/out/ /tool-store-data/ " >&2
if codemeta-harvester $HARVEST_OPTS --opts "$CODEMETAPY_OPTS" --outputdir /tmp/out "/usr/src/source-registry/$CONFIGPATH"; then

    #(re-)copy CSS
    cp -R /usr/lib/python3.*/site-packages/codemeta/resources/ /tmp/out/
    if [ -d /etc/css/ ]; then
        #allows providers to override CSS
        cp -f /etc/css/*.css /tmp/out/resources/
    fi

    #Creating HTML views and Turtle variants
    for f in /tmp/out/*.codemeta.json; do
        if [ -e "$f" ]  && [ "$(basename "$f")" != "all.json" ]; then
            echo "Creating HTML view for $(basename "$f")...">&2
            outfile=$(echo $f | sed -e 's/\.json$/.html/')
            codemetapy $CODEMETAPY_OPTS -o html "$f" > "$outfile"
            echo "Creating Turtle version for $(basename "$f")...">&2
            outfile=$(echo $f | sed -e 's/\.json$/.ttl/')
            codemetapy $CODEMETAPY_OPTS -o turtle "$f" > "$outfile"
        fi
    done

    #Creating joined graph
    echo "Creating joined graph (json)">&2
    codemetapy $CODEMETAPY_OPTS --graph /tmp/out/*.codemeta.json > /tmp/out/all.json || die "failed to create joined graph"
    echo "Creating joined graph (turtle)">&2
    codemetapy $CODEMETAPY_OPTS -o turtle --graph /tmp/out/*.codemeta.json > /tmp/out/all.ttl || die "failed to create joined graph"

    #Creating HTML index
    echo "Creating HTML index">&2
    codemetapy $CODEMETAPY_OPTS -o html --graph /tmp/out/*.codemeta.json > /tmp/out/index.html || die "failed to create HTML index"

    echo "Syncing temporary output to target dir">&2
    rsync --exclude 'archive' --delete -av /tmp/out/ /tool-store-data/ || die "failed to rsync"

    echo "Stopping the Tool Store API (will automatically restart)">&2
    killall uvicorn

    rm -Rf /tmp/out #cleanup
fi

