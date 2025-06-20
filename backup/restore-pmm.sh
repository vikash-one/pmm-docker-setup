#!/bin/bash

ENVIRONMENT=poc
VOLUME_NAME="pmm-${ENVIRONMENT}-data"
BACKUP_FILE="$1"

if [[ -z "$BACKUP_FILE" ]]; then
  echo "❌ Provide backup file path."
  echo "Usage: ./restore-pmm.sh /path/to/pmm-poc-data_YYYY-MM-DD-HH-MM.tar.gz"
  exit 1
fi

docker run --rm \
  -v $VOLUME_NAME:/data \
  -v $(dirname $BACKUP_FILE):/backup \
  alpine \
  sh -c "rm -rf /data/* && tar xzf /backup/$(basename $BACKUP_FILE) -C /data"

echo "✅ Restore completed for volume: $VOLUME_NAME"
