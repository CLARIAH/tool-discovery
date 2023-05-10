#!/bin/sh

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

if [ "$1" = "--purge" ]; then
    #this is run when invoked after the initial harvest
    echo "Clearing all previous output before collection">&2
    rm /tool-store-data/*.codemeta.json /tool-store-data/*.harvest.log
fi



#Script runs every CRON_BATCH_COLLECTOR_INTERVAL_MINS
#Remove files older than 2 minutes from this execution start time
TO_REMOVE=$(find /tmp/out/ -mmin +2 -type f)

echo "Syncing temporary output to target dir at $(date)">&2
rsync_out=$(rsync -c --include='*.codemeta.json' --exclude 'archive' -a --stats /tmp/out/ /tool-store-data/) || die "Failed to rsync"
echo "$rsync_out"

updated_files=$(echo $rsync_out | grep -Eo 'Number of regular files transferred: ([0-9]+)'| awk '{split($0,arr,": "); print arr[2]}')
echo "Updated files $updated_files ($(date))"
[ "$updated_files" = "0" ] && echo "rsync gave nothing to do (at $(date))" && exit 0

total_files=$(ls /tool-store-data/*.codemeta.json | wc -l)
[ "$total_files" = "0" ] && die "No codemeta files were produced after harvesting"

#Creating joined graph
echo "Creating a joined graph with: codemetapy --graph /tool-store-data/*.codemeta.json > /tool-store-data/data.json  --opts \"$CODEMETAPY_OPTS\"" >&2
codemetapy --graph /tool-store-data/*.codemeta.json > /tmp/data.json || die "failed to create joined graph"
mv -f /tmp/data.json /tool-store-data/data.json

echo "Stopping the Tool Store API (will automatically restart)">&2
killall uvicorn

#cleanup older than startTime - delta
if [ -n "$TO_REMOVE" ]; then
    rm -f $TO_REMOVE || true
fi

echo "Batch collector finished at $(date)">&2
