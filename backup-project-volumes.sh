#!/bin/bash

set -e

PROJECT_NAME=$1
BASE_VOLUMES_DIR=$2
DEST_DIR=$3

if [ "$PROJECT_NAME" == "" -o "$DEST_DIR" == "" -o "$BASE_VOLUMES_DIR" == "" ]; then
   echo "Usage: $0 [project name] [base volumes dir] [destination dir]"
   exit 1
fi

oc project $PROJECT_NAME
oc get pvc > /tmp/backup-volumes

DEST_DIR_BACKUP="$DEST_DIR/$(date +%s)"

mkdir -p $DEST_DIR_BACKUP

echo "Destination directory is $DEST_DIR_BACKUP"

while read line; do
  PVC_NAME=$(echo "$line"| cut -c 1-25 | tr -d '[:space:]')
  VOLUME_NAME=$(echo "$line"| cut -c 38-50 | tr -d '[:space:]')
  DEST_FILE=$DEST_DIR_BACKUP/$VOLUME_NAME-$PVC_NAME.tar.gz
  if [ -d $BASE_VOLUMES_DIR/$VOLUME_NAME ]; then
    echo ""
    echo "Archiving volume $BASE_VOLUMES_DIR/$VOLUME_NAME to $DEST_FILE..." 
    tar --checkpoint=.1000 -czf $DEST_FILE $BASE_VOLUMES_DIR/$VOLUME_NAME
  else
    if [ "$VOLUME_NAME" != "VOLUME" ]; then 
      echo "Volume dir $BASE_VOLUMES_DIR/$VOLUME_NAME not found"
    fi
  fi
done </tmp/backup-volumes

echo ""
echo "Done. Look for backup archives in $DEST_DIR_BACKUP"
