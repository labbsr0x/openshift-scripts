#!/bin/bash

set -e
set -x

PROJECT_NAME=$1
BASE_VOLUMES_DIR=$2
DEST_DIR=$3

if [ "$PROJECT_NAME" == "" -o "$DEST_DIR" == "" -o "$BASE_VOLUMES_DIR" == "" ]; then
   echo "Usage: $0 [project name] [base volumes dir] [destination dir]"
   exit 1
fi

oc project $PROJECT_NAME
oc get pvc | cut -c 38-50 > /tmp/backup-volumes

DEST_DIR_BACKUP="$DEST_DIR/$(date +%s)"

mkdir -p $DEST_DIR_BACKUP

echo "Archiving project volumes to $DEST_DIR_BACKUP"

while read p; do
  if [ -d $BASE_VOLUMES_DIR/$p ]; then
    echo "Archiving volume $p..." 
    tar --checkpoint=.500 -czf $DEST_DIR_BACKUP/$p.tar.gz $BASE_VOLUMES_DIR/$p
  else
    if [ "$p" != "VOLUME" ]; then 
      echo "Volume dir $BASE_VOLUMES_DIR/$p not found"
    fi
  fi
done </tmp/backup-volumes

echo "Done. Look for backup archives in $DEST_DIR_BACKUP"
