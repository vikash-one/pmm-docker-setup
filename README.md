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
=========================================================================================
# 🖥️ PMM Docker Setup with Backup/Restore

This repo provides production-ready scripts and Docker Compose files to deploy and maintain Percona Monitoring and Management (PMM) in both PoC and Prod environments.

## 🧱 Setup

```bash
cd install/
chmod +x install-docker-and-setup-pmm.sh
./install-docker-and-setup-pmm.sh
=======================================================================================
pmm-docker-setup/
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