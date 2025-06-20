Here’s a **single consolidated shell script** that:

* Installs **Docker** and **Docker Compose (v2)**
* Sets up required packages on **Ubuntu 24.04 EC2**
* Prepares the host for **both PoC and Production** PMM Docker deployments

---

## ✅ Script: `install-docker-and-setup-pmm.sh`

```bash
#!/bin/bash

set -e

echo "📦 Updating packages and installing dependencies..."
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

echo "🐳 Installing Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "🔧 Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "👤 Adding current user (${USER}) to docker group..."
sudo usermod -aG docker $USER
newgrp docker <<EONG
echo "✅ Docker group applied to shell. You can now run docker commands without sudo."
EONG

echo "✅ Verifying Docker installation..."
docker --version
docker compose version

echo "📁 Setting up PMM deployment directory..."
mkdir -p ~/pmm-docker
cd ~/pmm-docker

echo "✅ Setup complete. Now place your docker-compose files and .env here:"
echo "   ~/pmm-docker/"
```

---

## ✅ How to Use

```bash
chmod +x install-docker-and-setup-pmm.sh
./install-docker-and-setup-pmm.sh
```

> 💡 After installation, **log out and log in again** if the `docker` group doesn't take effect immediately.

---

## 🧪 What’s Ready After This?

Once this script finishes:

* You’ll have Docker + Docker Compose installed on Ubuntu 24.04
* Your PMM setup directory is created at `~/pmm-docker`
* You can copy in your:

  * `.env`
  * `docker-compose.base.yml`
  * `docker-compose.poc.yml`
  * `docker-compose.prod.yml`

Then run:

```bash
# Example for PoC
docker compose -f docker-compose.base.yml -f docker-compose.poc.yml --env-file .env up -d
```

---

Would you like a second script for **automated backup/restore** of the PMM volumes next?
