Here's a **safe, production-ready backup & restore script pair** for your PMM setup using Docker volumes.

---

## 🗂 Folder Structure

```
~/pmm-docker/
├── backup/
│   ├── backup-pmm.sh
│   └── restore-pmm.sh
```

---

## 📦 `backup/backup-pmm.sh` – PMM Volume Backup

```bash
#!/bin/bash

# PMM Volume Name (update for prod or poc)
VOLUME_NAME="pmm-server-data"  # or use "pmm-poc-data" for PoC
BACKUP_DIR="/opt/pmm-backup"
TIMESTAMP=$(date +%F-%H-%M)
BACKUP_FILE="${BACKUP_DIR}/${VOLUME_NAME}_${TIMESTAMP}.tar.gz"

set -e

echo "📦 Creating backup directory: $BACKUP_DIR"
sudo mkdir -p "$BACKUP_DIR"

echo "🔒 Backing up Docker volume: $VOLUME_NAME"
docker run --rm \
  -v $VOLUME_NAME:/data:ro \
  -v $BACKUP_DIR:/backup \
  alpine \
  sh -c "tar czf /backup/${VOLUME_NAME}_${TIMESTAMP}.tar.gz -C /data ."

echo "✅ Backup created: $BACKUP_FILE"
```

---

## 🔁 `backup/restore-pmm.sh` – Restore PMM Volume from Backup

```bash
#!/bin/bash

# PMM Volume Name (update as needed)
VOLUME_NAME="pmm-server-data"  # or "pmm-poc-data"
BACKUP_FILE="$1"  # Full path to the .tar.gz backup file

if [[ -z "$BACKUP_FILE" ]]; then
  echo "❌ Please provide backup file path as argument."
  echo "Usage: ./restore-pmm.sh /opt/pmm-backup/pmm-server-data_YYYY-MM-DD.tar.gz"
  exit 1
fi

echo "♻️ Restoring Docker volume: $VOLUME_NAME from $BACKUP_FILE"

# Create temp container to populate volume
docker run --rm \
  -v $VOLUME_NAME:/data \
  -v $(dirname $BACKUP_FILE):/backup \
  alpine \
  sh -c "rm -rf /data/* && tar xzf /backup/$(basename $BACKUP_FILE) -C /data"

echo "✅ Restore completed for volume: $VOLUME_NAME"
```

---

## ✅ Usage Example

```bash
# Run Backup
./backup/backup-pmm.sh

# List Backups
ls /opt/pmm-backup

# Restore Backup
./backup/restore-pmm.sh /opt/pmm-backup/pmm-server-data_2025-06-20-18-30.tar.gz
```

---

## 📌 Notes

* These scripts use a **temporary Alpine container** to access and archive volume contents.
* Change `VOLUME_NAME` to `pmm-poc-data` if working in PoC mode.
* Run backups periodically via **cron or Jenkins**.

---

Would you like me to:

* Integrate this into your Jenkins pipeline?
* Add backup rotation (keep last N files)?
* Support S3/remote backup upload as next step?
