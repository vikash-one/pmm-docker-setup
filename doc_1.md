Great — here is the **complete GitHub-ready folder structure** (without GitHub Actions) to manage both **PoC** and **Production** PMM setups using Docker Compose:

---

## 📁 Folder Structure

```
pmm-docker/
├── .env.example
├── docker-compose.base.yml
├── docker-compose.poc.yml
├── docker-compose.prod.yml
├── Jenkinsfile
└── README.md
```

---

## 1. `.env.example`

```env
PMM_TAG=3
PMM_PORT=443
WATCHTOWER_TOKEN=secure-token-here
```

---

## 2. `docker-compose.base.yml`

```yaml
version: '3.8'

services:
  pmm-server:
    image: percona/pmm-server:${PMM_TAG}
    container_name: pmm-server
    restart: always
    ports:
      - "${PMM_PORT}:8443"
    environment:
      - PMM_WATCHTOWER_HOST=http://watchtower:8080
      - PMM_WATCHTOWER_TOKEN=${WATCHTOWER_TOKEN}
    networks:
      - pmm-net

  watchtower:
    image: percona/watchtower
    container_name: watchtower
    restart: always
    environment:
      - WATCHTOWER_HTTP_API_TOKEN=${WATCHTOWER_TOKEN}
      - WATCHTOWER_HTTP_LISTEN_PORT=8080
      - WATCHTOWER_HTTP_API_UPDATE=1
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - pmm-net

networks:
  pmm-net:
    driver: bridge
```

---

## 3. `docker-compose.poc.yml`

```yaml
version: '3.8'

services:
  pmm-server:
    volumes:
      - pmm-poc-data:/srv

volumes:
  pmm-poc-data:
```

---

## 4. `docker-compose.prod.yml`

```yaml
version: '3.8'

services:
  pmm-server:
    volumes:
      - pmm-server-data:/srv

volumes:
  pmm-server-data:
```

---

## 5. `Jenkinsfile`

```groovy
pipeline {
  parameters {
    choice(name: 'ENV_TYPE', choices: ['poc', 'prod'], description: 'Choose environment')
  }

  agent any

  stages {
    stage('Deploy PMM') {
      steps {
        script {
          sh 'cp .env.example .env'
          sh """
            docker compose -f docker-compose.base.yml -f docker-compose.${params.ENV_TYPE}.yml \
              --env-file .env up -d
          """
        }
      }
    }
  }
}
```

---

## 6. `README.md`

````markdown
# 🖥️ PMM Docker Setup

Modular setup for Percona Monitoring and Management (PMM) via Docker Compose.

## 🏗️ Structure

- `docker-compose.base.yml`: Common base (PMM + Watchtower)
- `docker-compose.poc.yml`: PoC-specific volumes
- `docker-compose.prod.yml`: Prod-specific volumes
- `.env.example`: Shared environment variables

## 🧪 Usage

### Run PoC
```bash
cp .env.example .env
docker compose -f docker-compose.base.yml -f docker-compose.poc.yml --env-file .env up -d
````

### Run Production

```bash
cp .env.example .env
docker compose -f docker-compose.base.yml -f docker-compose.prod.yml --env-file .env up -d
```

## 🧰 Jenkins Support

Use `ENV_TYPE` as `poc` or `prod` in the Jenkins pipeline.

```

---

## ✅ Ready to Zip?

Would you like me to generate a **.zip file** with all of these pre-filled files?  
Or just copy to your GitHub repo manually?

Let me know if you'd also like to integrate:

- 🔄 PMM client auto-registering for EC2/RDS
- 🧩 Backup/restore volume scripts
- 📊 Pre-built dashboards and templates setup

All optional based on how far you want to scale this.
```
