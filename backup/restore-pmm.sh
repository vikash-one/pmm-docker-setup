#!/bin/bash
VOLUME_NAME="pmm-server-data"  # or "pmm-poc-data"
BACKUP_FILE="$1"

if [[ -z "$BACKUP_FILE" ]]; then
  echo "❌ Provide the backup .tar.gz file path"
  echo "Usage: ./restore-pmm.sh /opt/pmm-backup/pmm-server-data_YYYY-MM-DD.tar.gz"
  exit 1
fi

docker run --rm \
  -v $VOLUME_NAME:/data \
  -v $(dirname $BACKUP_FILE):/backup \
  alpine \
  sh -c "rm -rf /data/* && tar xzf /backup/$(basename $BACKUP_FILE) -C /data"

echo "✅ Restore completed for $VOLUME_NAME"
