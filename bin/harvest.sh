#!/bin/sh

# this script can be invoked periodically from cron


die() {
    echo "$@" >&2
    exit 1
}

BASEURI="${1:-$BASEURL}"
CSS="$BASEURI/resources/codemeta.css,$BASEURI/resources/fontawesome.css"
if [ -n "$BASEURI" ]; then
    HARVEST_OPTS="--baseuri $1"
    CODEMETAPY_OPTS="--baseuri $1 --toolstore --css $CSS"
else
    HARVEST_OPTS=""
    CODEMETAPY_OPTS="--toolstore --css $CSS"
fi

if [ "$CODEMETA_VALIDATE" = "true" ]; then
    HARVEST_OPTS="$HARVEST_OPTS --validate /etc/software.ttl"
    if [ -n "$VALIDATION_TEXT" ]; then
        HARVEST_OPTS="$HARVEST_OPTS --validatetext '$VALIDATION_TEXT'"
    fi
fi

echo "Starting Harvester at $(date)">&2
if [ -n "$GITHUB_TOKEN" ]; then
    echo "(Github API access token is set)" >&2
    echo "$GITHUB_TOKEN" > /tmp/github_token
    chmod go-rwx /tmp/github_token
elif [ -e /tmp/github_token ]; then
    export GITHUB_TOKEN=$(cat /tmp/github_token)
    echo "(Github API access token is read from file)" >&2
else
    echo "(Github API access token is not set)" >&2
fi


mkdir -p /usr/src/
if [ "$LOCAL_SOURCE_REGISTRY" != "true" ]; then
    CONFIGURL="${2:-$SOURCE_REGISTRY_REPO}"
    [ -n "$CONFIGURL" ] || die "No configuration URL provided (expected a git repository)"
    # Update the source registry containing the configuration for codemeta-harvester
    if [ ! -d /usr/src/source-registry ]; then
        echo "Cloning configuration repository $CONFIGURL">&2
        cd /usr/src
        git clone "$CONFIGURL" source-registry || die "Unable to clone source registry"
        cd -
    else
        echo "Updating configuration repository $CONFIGURL">&2
        cd /usr/src/source-registry
        git pull || die "Unable to update source registry"
        cd -
    fi
fi

#Run the codemeta-harvester
CONFIGPATH="${3:-$SOURCE_REGISTRY_ROOT}"
echo "Invoking harvester: codemeta-harvester $HARVEST_OPTS --opts \"$CODEMETAPY_OPTS\" --outputdir /tmp/out /usr/src/source-registry/$CONFIGPATH" >&2
codemeta-harvester $HARVEST_OPTS --opts "$CODEMETAPY_OPTS" --outputdir /tmp/out "/usr/src/source-registry/$CONFIGPATH" 2>&1 | tee /tmp/out/harvest.log

echo "codemeta-harvester finished at $(date)">&2
