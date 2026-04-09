#!/bin/sh

# this script can be invoked periodically from cron

die() {
    echo "$@" >&2
    exit 1
}

cd /tmp || die "no temp dir"
echo "codemeta2mp starting at $(date)">&2
codemeta2mp --pause 1 --baseurl https://marketplace-api.sshopencloud.eu/ --username "$MARKETPLACE_USERNAME" --password "$MARKETPLACE_PASSWORD" --exclude "$MARKETPLACE_EXCLUDE" /tool-store-data/data.json || die "codemeta2mp failed"
echo "codemeta2mp finished at $(date)">&2
