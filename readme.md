Below are **two complete and conflict-free Docker Compose setups** for:

* ✅ **PoC** PMM environment
* ✅ **Production** PMM environment

Each handles:

* Named **container** and **volume**
* Separate **host port** mappings (no conflict)
* Shared base config (`pmm-server` + `watchtower`)

---

## 📁 Folder Structure

```
pmm-docker-setup/
├── .env.poc
├── .env.prod
├── docker-compose.base.yml
├── docker-compose.poc.yml
├── docker-compose.prod.yml
└── README.md
```

---

## ✅ `.env.poc`

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

## ✅ `.env.prod`

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

## ✅ `docker-compose.base.yml`

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

## ✅ `docker-compose.poc.yml`

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

## ✅ `docker-compose.prod.yml`

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

## 🚀 How to Deploy

### ▶ PoC

```bash
cp .env.poc .env
docker compose -f docker-compose.base.yml -f docker-compose.poc.yml --env-file .env up -d
```

### ▶ Production

```bash
cp .env.prod .env
docker compose -f docker-compose.base.yml -f docker-compose.prod.yml --env-file .env up -d
```

---

## 🌐 Access URLs

| Environment | PMM URL               | Watchtower API URL   |
| ----------- | --------------------- | -------------------- |
| PoC         | `https://<host>:8443` | `http://<host>:8081` |
| Prod        | `https://<host>:443`  | `http://<host>:8080` |

---

## 🛑 Bonus: Port Conflict Guard (optional helper)

```bash
if ss -tuln | grep -q ":443"; then
  echo "❌ Port 443 already in use. Cannot start production PMM."
  exit 1
fi
```

---

Would you like me to:

* Zip this into a ready-to-download archive?
* Add **Jenkinsfile** logic for auto-deploying either setup?
* Add a **firewall rule script** to block PoC from public IPs?
