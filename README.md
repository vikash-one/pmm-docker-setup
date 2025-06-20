# PMM Docker PoC Setup

Deploy PMM Server in Docker using modular, environment-aware Docker Compose.

## 🔧 Install Docker (Ubuntu 24.04)

```bash
cd install/
chmod +x install-docker-and-setup-pmm.sh
./install-docker-and-setup-pmm.sh
#*************************************************************************************************************************************************
pmm-docker-setup/
├── .env.example
├── docker-compose.base.yml
├── docker-compose.poc.yml
├── install/
│   └── install-docker-and-setup-pmm.sh
├── backup/
│   ├── backup-pmm.sh
│   └── restore-pmm.sh
└── README.md
#*************************************************************************************************************************************************
