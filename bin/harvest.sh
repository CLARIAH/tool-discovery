#!/bin/sh

# this script can be invoked periodically from cron


die() {
    echo "$@" >&2
    exit 1
}

BASEURI="${1:-$BASEURL}"
CSS="$BASEURI/resources/codemeta.css,$BASEURI/resources/fontawesome.css"
if [ -n "$BASEURI" ]; then
    HARVEST_OPTS="--baseuri $BASEURI"
    CODEMETAPY_OPTS="--baseuri $BASEURI --toolstore --css $CSS $CODEMETAPY_EXTRA_OPTS"
else
    HARVEST_OPTS=""
    CODEMETAPY_OPTS="--toolstore --css $CSS $CODEMETAPY_EXTRA_OPTS"
fi

if [ "$CODEMETA_VALIDATE" = "true" ]; then
    HARVEST_OPTS="$HARVEST_OPTS --validate /etc/software.ttl"
fi
if [ "$CODEMETA_DEBUG" = "true" ]; then
    HARVEST_OPTS="$HARVEST_OPTS --debug"
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

if [ -n "$ZENODO_ACCESS_TOKEN" ]; then
    echo "(zenodo API access token is set)" >&2
    echo "$ZENODO_ACCESS_TOKEN" > /tmp/zenodo_token
    chmod go-rwx /tmp/zenodo_token
elif [ -e /tmp/zenodo_token ]; then
    export ZENODO_ACCESS_TOKEN=$(cat /tmp/zenodo_token)
    echo "(zenodo API access token is read from file)" >&2
else
    echo "(zenodo API access token is not set)" >&2
fi


mkdir -p /usr/src/
if [ "$LOCAL_SOURCE_REGISTRY" != "true" ]; then
    CONFIGURL="${2:-$SOURCE_REGISTRY_REPO}"
    [ -n "$CONFIGURL" ] || die "No configuration URL provided (expected a git repository)"
    OLDPWD=$(pwd)
    # Update the source registry containing the configuration for codemeta-harvester
    if [ ! -d /usr/src/source-registry ]; then
        echo "Cloning configuration repository $CONFIGURL">&2
        cd /usr/src
        git clone "$CONFIGURL" source-registry || die "Unable to clone source registry"
        if [ -n "$SOURCE_REGISTRY_BRANCH" ]; then
            cd source-registry
            git checkout "$SOURCE_REGISTRY_BRANCH" || die "Unable to checkout branch $SOURCE_REGISTRY_BRANCH"
        fi
        cd "$OLDPWD"
    else
        echo "Updating configuration repository $CONFIGURL">&2
        cd /usr/src/source-registry
        git pull || die "Unable to update source registry"
        if [ -n "$SOURCE_REGISTRY_BRANCH" ]; then
            git checkout "$SOURCE_REGISTRY_BRANCH" || die "Unable to checkout branch $SOURCE_REGISTRY_BRANCH"
        fi
        cd "$OLDPWD"
    fi
fi


#ensure context cache is redownloaded every harvest
rm /tmp/*.jsonld 2>/dev/null

#Run the codemeta-harvester
CONFIGPATH="${3:-$SOURCE_REGISTRY_ROOT}"
echo "Invoking harvester: codemeta-harvester $HARVEST_OPTS --validatetext \"$VALIDATION_TEXT\" --opts \"$CODEMETAPY_OPTS\" --outputdir /tmp/out /usr/src/source-registry/$CONFIGPATH" >&2
codemeta-harvester $HARVEST_OPTS --validatetext "$VALIDATION_TEXT" --opts "$CODEMETAPY_OPTS" --outputdir /tmp/out "/usr/src/source-registry/$CONFIGPATH" 2>&1 | tee /tmp/out/harvest.log

echo "codemeta-harvester finished at $(date)">&2
