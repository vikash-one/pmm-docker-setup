#!/bin/bash

ENVIRONMENT=poc
VOLUME_NAME="pmm-${ENVIRONMENT}-data"
BACKUP_DIR="/opt/pmm-backup"
TIMESTAMP=$(date +%F-%H-%M)
BACKUP_FILE="${BACKUP_DIR}/${VOLUME_NAME}_${TIMESTAMP}.tar.gz"

set -e
sudo mkdir -p "$BACKUP_DIR"

docker run --rm \
  -v $VOLUME_NAME:/data:ro \
  -v $BACKUP_DIR:/backup \
  alpine \
  sh -c "tar czf /backup/${VOLUME_NAME}_${TIMESTAMP}.tar.gz -C /data ."

echo "✅ Backup created: $BACKUP_FILE"
