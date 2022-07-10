#!/bin/bash

die() {
    echo "$@" >&2
    exit 1
}

PIDFILE="/tmp/action1.pid"
create_pidfile () {
  echo $$ > "$PIDFILE"
}

remove_pidfile () {
  [ -f "$PIDFILE" ] && rm "$PIDFILE"
}

#To handle the case that 1) the previous running cron went long
# or 2) the process was interrupted in the middle
trap remove_pidfile EXIT
create_pidfile

BASEURI="$BASEURL"
CSS="$BASEURI/resources/codemeta.css,$BASEURI/resources/fontawesome.css"
if [ -n "$1" ]; then
    HARVEST_OPTS="--baseuri $BASEURI"
else
    HARVEST_OPTS=""
    CODEMETAPY_OPTS="--toolstore --css $CSS"
fi

#Script runs every CRON_BATCH_COLLECTOR_INTERVAL_MINS
#Remove files older than 2 minutes from this execution start time
TO_REMOVE=$(find /tmp/out/ -mmin +2 -type f)

echo "Syncing temporary output to target dir">&2
rsync_out=$(rsync -c --include='*.codemeta.json' --exclude 'archive' -a --stats  /tmp/out/ /tool-store-data/) || die "Nothing to do or failed to rsync"
echo "$rsync_out"

updated_files=`echo $rsync_out | grep -Eo 'Number of regular files transferred: ([0-9]+)'| awk '{split($0,arr,": "); print arr[2]}'`
echo "Updated files $updated_files"
[ "$updated_files" == "0" ] && echo "rsync gave nothing to do" && exit 0


#Creating joined graph
echo "Creating a joined graph with: codemetapy --graph /tool-store-data/*.codemeta.json > /tool-store-data/data.json  --opts \"$CODEMETAPY_OPTS\"" >&2
codemetapy $CODEMETAPY_OPTS --graph /tool-store-data/*.codemeta.json > /tmp/data.json || die "failed to create joined graph"
mv -f /tmp/data.json /tool-store-data/data.json

echo "Stopping the Tool Store API (will automatically restart)">&2
killall uvicorn

#cleanup older than startTime - delta
rm -f $TO_REMOVE || true

echo "Batch collector finished at $(date)">&2
