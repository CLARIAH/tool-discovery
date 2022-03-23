#!/bin/sh

# this script is typically invoked periodically from cron


die() {
    echo "$@" >&2
    exit 1
}

if [ -n "$1" ]; then
    BASEURI="$1"
    OPTS="--baseuri \"$1\""
else
    OPTS=""
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
echo "Invoking harvester: codemeta-harvester $OPTS --outputdir /tmp/out /usr/src/source-registry/$CONFIGPATH && rsync --delete -av /tmp/out/ /tool-store-data/ " >&2
if codemeta-harvester $OPTS --outputdir /tmp/out "/usr/src/source-registry/$CONFIGPATH"; then

    #(re-)copy CSS
    cp -f /usr/lib/python3.*/site-packages/codemeta/resources/*.css /tool-store-data/
    if [ -d /etc/css/ ]; then
    #allows providers to override CSS
    cp -f /etc/css/*.css /tool-store-data/
    fi

    #Creating HTML views
    for f in /tmp/out/*.json; do
        echo "Creating HTML view for $(basename "$f")...">&2
        if [ -e "$f" ]  && [ "$(basename "$f")" != "index.json" ]; then
            outfile=$(echo $f | sed -e 's/\.json$/.html/')
            codemetapy $OPTS -o html --css "$BASEURI/codemeta.css" "$f" > "$outfile"
        fi
    done

    #Creating joined graph
    echo "Creating joined graph: codemetapy --graph /tmp/out/*.json > /tmp/out/index.json">&2
    codemetapy $OPTS --graph /tmp/out/*.json > /tmp/out/index.json || die "failed to create joined graph"

    #Creating HTML index
    codemetapy $OPTS -o html --graph --css "$BASEURI/codemeta.css" /tmp/out/*.json > /tmp/out/index.html || die "failed to create HTML index"

    echo "Syncing to target dir">&2
    rsync --delete -av /tmp/out/ /tool-store-data/ || die "failed to rsync"

    rm -Rf /tmp/out #cleanup
fi

