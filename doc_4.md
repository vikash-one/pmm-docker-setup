Here's a clean **GitHub-style repository structure** for your PMM Docker setup with **backup & restore support**, ideal for version control and CI/CD pipelines like Jenkins.

---

## 📁 GitHub Repo Structure: `pmm-docker`

```
pmm-docker/
├── .env.example
├── docker-compose.base.yml
├── docker-compose.poc.yml
├── docker-compose.prod.yml
├── install/
│   └── install-docker-and-setup-pmm.sh
├── backup/
│   ├── backup-pmm.sh
│   └── restore-pmm.sh
├── Jenkinsfile
└── README.md
```

---

## 📂 `install/install-docker-and-setup-pmm.sh`

> Already provided above — installs Docker + Docker Compose and prepares the `pmm-docker` folder.

---

## 📂 `backup/backup-pmm.sh`

```bash
#!/bin/bash
VOLUME_NAME="pmm-server-data"  # or "pmm-poc-data"
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
```

---

## 📂 `backup/restore-pmm.sh`

```bash
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
```

---

## 📄 `README.md`

````markdown
# 🖥️ PMM Docker Setup with Backup/Restore

This repo provides production-ready scripts and Docker Compose files to deploy and maintain Percona Monitoring and Management (PMM) in both PoC and Prod environments.

## 🧱 Setup

```bash
cd install/
chmod +x install-docker-and-setup-pmm.sh
./install-docker-and-setup-pmm.sh
````

## 🚀 Running PMM

```bash
# PoC
docker compose -f docker-compose.base.yml -f docker-compose.poc.yml --env-file .env up -d

# Production
docker compose -f docker-compose.base.yml -f docker-compose.prod.yml --env-file .env up -d
```

## 💾 Backup & Restore

```bash
cd backup/

# Create backup
./backup-pmm.sh

# Restore backup
./restore-pmm.sh /opt/pmm-backup/pmm-server-data_YYYY-MM-DD-HH-MM.tar.gz
```

```

---

## ✅ GitHub Repo Naming Suggestion

Name the repository:

```

freecharge/pmm-docker-setup

```

---

## 👉 Next Steps?

Would you like a **ready-to-import `.zip` of this repo**, or a **`git init` + push guide** to publish to GitHub?

Also, I can add:

- ⏱️ Cron-compatible backup rotation script
- ☁️ S3 sync support
- 🔒 Vault/Secrets management integration for Jenkins

Let me know how you'd like to scale this repo.
```
