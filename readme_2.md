Here is the **complete PoC + Production-ready PMM Docker setup** with:

1. ✅ Docker & Docker Compose **installation script**
2. ✅ Environment-aware **backup & restore scripts**
3. ✅ Dependency management
4. ✅ Conflict-free **volume & container naming**
5. ✅ GitHub-style layout for version control

---

## 📁 Recommended GitHub Repo Structure: `pmm-docker-setup`

```
pmm-docker-setup/
├── .env.poc
├── .env.prod
├── docker-compose.base.yml
├── docker-compose.poc.yml
├── docker-compose.prod.yml
├── install/
│   └── install-docker-and-deps.sh
├── backup/
│   ├── backup-pmm.sh
│   └── restore-pmm.sh
├── README.md
```

---

### ✅ `install/install-docker-and-deps.sh`

```bash
#!/bin/bash
set -e

echo "📦 Installing Docker & Docker Compose on Ubuntu 24.04..."

sudo apt update -y
sudo apt upgrade -y
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    unzip \
    software-properties-common \
    apt-transport-https

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "✅ Docker installed."

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker "$USER"

echo "✅ Docker service started and user added to docker group (may need re-login)."
```

---

### ✅ `backup/backup-pmm.sh`

```bash
#!/bin/bash

# Usage: ./backup-pmm.sh [poc|prod]
ENVIRONMENT="${1:-poc}"
VOLUME_NAME="pmm-${ENVIRONMENT}-data"
BACKUP_DIR="/opt/pmm-backup"
TIMESTAMP=$(date +%F-%H-%M)
BACKUP_FILE="${BACKUP_DIR}/${VOLUME_NAME}_${TIMESTAMP}.tar.gz"

echo "📦 Backing up volume: $VOLUME_NAME"

set -e
sudo mkdir -p "$BACKUP_DIR"

docker run --rm \
  -v $VOLUME_NAME:/data:ro \
  -v $BACKUP_DIR:/backup \
  alpine \
  sh -c "tar czf /backup/$(basename "$BACKUP_FILE") -C /data ."

echo "✅ Backup created at: $BACKUP_FILE"
```

---

### ✅ `backup/restore-pmm.sh`

```bash
#!/bin/bash

# Usage: ./restore-pmm.sh /opt/pmm-backup/pmm-poc-data_2025-06-20.tar.gz [poc|prod]
BACKUP_FILE="$1"
ENVIRONMENT="${2:-poc}"
VOLUME_NAME="pmm-${ENVIRONMENT}-data"

if [[ -z "$BACKUP_FILE" ]]; then
  echo "❌ Please provide backup file path."
  echo "Usage: ./restore-pmm.sh /path/to/file.tar.gz [poc|prod]"
  exit 1
fi

echo "♻️ Restoring volume: $VOLUME_NAME from $BACKUP_FILE"

docker run --rm \
  -v $VOLUME_NAME:/data \
  -v $(dirname "$BACKUP_FILE"):/backup \
  alpine \
  sh -c "rm -rf /data/* && tar xzf /backup/$(basename "$BACKUP_FILE") -C /data"

echo "✅ Restore complete for volume: $VOLUME_NAME"
```

---

### ✅ `.env.poc`

```env
PMM_TAG=3
PMM_PORT=8443
WATCHTOWER_PORT=8081
WATCHTOWER_TOKEN=secure-poc-token
ENVIRONMENT=poc
PMM_CONTAINER_NAME=pmm-server-${ENVIRONMENT}
PMM_VOLUME_NAME=pmm-${ENVIRONMENT}-data
```

---

### ✅ `.env.prod`

```env
PMM_TAG=3
PMM_PORT=443
WATCHTOWER_PORT=8080
WATCHTOWER_TOKEN=secure-prod-token
ENVIRONMENT=prod
PMM_CONTAINER_NAME=pmm-server-${ENVIRONMENT}
PMM_VOLUME_NAME=pmm-${ENVIRONMENT}-data
```

---

### ✅ `docker-compose.base.yml`

```yaml
version: '3.8'

services:
  pmm-server:
    image: percona/pmm-server:${PMM_TAG}
    container_name: ${PMM_CONTAINER_NAME}
    restart: always
    ports:
      - "${PMM_PORT}:8443"
    environment:
      - PMM_WATCHTOWER_HOST=http://watchtower:${WATCHTOWER_PORT}
      - PMM_WATCHTOWER_TOKEN=${WATCHTOWER_TOKEN}
    networks:
      - pmm-net

  watchtower:
    image: percona/watchtower
    container_name: watchtower-${ENVIRONMENT}
    restart: always
    environment:
      - WATCHTOWER_HTTP_API_TOKEN=${WATCHTOWER_TOKEN}
      - WATCHTOWER_HTTP_LISTEN_PORT=${WATCHTOWER_PORT}
      - WATCHTOWER_HTTP_API_UPDATE=1
    ports:
      - "${WATCHTOWER_PORT}:${WATCHTOWER_PORT}"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - pmm-net

networks:
  pmm-net:
    driver: bridge
```

---

### ✅ `docker-compose.poc.yml`

```yaml
version: '3.8'

services:
  pmm-server:
    volumes:
      - pmm-poc-data:/srv

volumes:
  pmm-poc-data:
    name: pmm-poc-data
```

---

### ✅ `docker-compose.prod.yml`

```yaml
version: '3.8'

services:
  pmm-server:
    volumes:
      - pmm-prod-data:/srv

volumes:
  pmm-prod-data:
    name: pmm-prod-data
```

---

### ✅ `README.md` (Partial)

````markdown
# PMM Docker Setup

## 🚀 Quick Start

```bash
# Install Docker & Compose (Ubuntu 24.04)
cd install/
chmod +x install-docker-and-deps.sh
./install-docker-and-deps.sh
````

## 🧪 Start PMM PoC

```bash
cp .env.poc .env
docker compose -f docker-compose.base.yml -f docker-compose.poc.yml --env-file .env up -d
```

## 🛡️ Start PMM Production

```bash
cp .env.prod .env
docker compose -f docker-compose.base.yml -f docker-compose.prod.yml --env-file .env up -d
```

## 💾 Backup

```bash
./backup/backup-pmm.sh poc
./backup/backup-pmm.sh prod
```

## ♻️ Restore

```bash
./backup/restore-pmm.sh /opt/pmm-backup/pmm-poc-data_YYYY-MM-DD.tar.gz poc
```

## 🌐 Access PMM

| Env  | PMM URL                                | Watchtower API                       |
| ---- | -------------------------------------- | ------------------------------------ |
| PoC  | [https://host:8443](https://host:8443) | [http://host:8081](http://host:8081) |
| Prod | [https://host:443](https://host:443)   | [http://host:8080](http://host:8080) |

```

---

## ✅ Next Options

Would you like me to:

- 🗜️ Send this as a downloadable `.zip`?
- 📦 Convert to a GitHub template repo?
- ✍️ Add cron/jenkins pipeline for auto-backup?

Let me know how you'd like to proceed.
```
