#!/bin/bash
# ec2-setup.sh
# Run this ONCE on a fresh Ubuntu 22.04 EC2 instance.
# Installs: Docker, Docker Compose, Java 17, Jenkins
# Usage: bash ec2-setup.sh

set -e  # Exit on any error

echo "=============================================="
echo "  EC2 Server Setup: Docker + Jenkins"
echo "=============================================="

# ── 1. System Update ─────────────────────────────
echo ""
echo "📦 [1/6] Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# ── 2. Install Docker ─────────────────────────────
echo ""
echo "🐳 [2/6] Installing Docker..."
sudo apt-get install -y ca-certificates curl gnupg lsb-release

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add ubuntu user to docker group (no sudo needed for docker commands)
sudo usermod -aG docker ubuntu
sudo systemctl enable docker
sudo systemctl start docker

echo "✅ Docker installed: $(docker --version)"

# ── 3. Install Docker Compose (standalone) ────────
echo ""
echo "🔧 [3/6] Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo "✅ Docker Compose installed: $(docker-compose --version)"

# ── 4. Install Java 17 (required for Jenkins) ────
echo ""
echo "☕ [4/6] Installing Java 17..."
sudo apt-get install -y openjdk-17-jdk
echo "✅ Java installed: $(java -version 2>&1 | head -1)"

# ── 5. Install Jenkins ────────────────────────────
echo ""
echo "🔧 [5/6] Installing Jenkins..."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/" | \
    sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y jenkins

# Add jenkins user to docker group so Jenkins can run docker commands
sudo usermod -aG docker jenkins

sudo systemctl enable jenkins
sudo systemctl start jenkins
echo "✅ Jenkins installed and started"

# ── 6. Install git & curl ─────────────────────────
echo ""
echo "🛠️  [6/6] Installing Git and Curl..."
sudo apt-get install -y git curl
echo "✅ Git installed: $(git --version)"

# ── Summary ───────────────────────────────────────
echo ""
echo "=============================================="
echo "  ✅ Setup Complete!"
echo "=============================================="
echo ""
echo "  🔑 Jenkins Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo ""
echo "  🌐 Access Jenkins at: http://$(curl -s ifconfig.me):8080"
echo ""
echo "  ⚠️  NOTE: Log out and log back in (or run 'newgrp docker')"
echo "           so 'ubuntu' user docker group takes effect."
echo "=============================================="
