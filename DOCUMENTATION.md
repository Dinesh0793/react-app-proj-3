# DevOps Project Documentation
## React App — CI/CD Pipeline with Docker, Jenkins, AWS & Monitoring

---

## 📌 Project Overview

This project demonstrates a complete **end-to-end DevOps pipeline** for deploying a React web application to production on AWS. It covers containerization, CI/CD automation, cloud deployment, and monitoring.

**Application:** React-based OnlineShop (pre-built static site)  
**Server:** Nginx (serves React app on port 80)  
**Cloud:** AWS EC2 (t3.micro, Ubuntu 22.04)  
**Live URL:** http://13.232.74.74


## 🔧 Step-by-Step Implementation

### Phase 1 — Application & Docker Setup

#### Step 1.1 — Dockerfile
The app uses a **single-stage Docker build** with `nginx:alpine`:
```dockerfile
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY build/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```
- Base image: `nginx:alpine` (lightweight, ~5MB)
- Copies pre-built React files directly
- Exposes port 80

#### Step 1.2 — Nginx Configuration (`nginx.conf`)
- Serves static React files
- Supports **React Router** (`try_files $uri /index.html`)
- Exposes `/nginx_status` endpoint for Prometheus metrics scraping
- Enables Gzip compression for performance

#### Step 1.3 — Docker Compose (`docker-compose.yml`)
Runs 6 containers in a shared network:

| Container | Image | Port |
|-----------|-------|------|
| react-app | `dinesh0793/dev:latest` | 80 |
| nginx-exporter | `nginx/nginx-prometheus-exporter` | 9113 |
| node-exporter | `prom/node-exporter` | 9100 |
| prometheus | `prom/prometheus` | 9090 |
| alertmanager | `prom/alertmanager` | 9093 |
| grafana | `grafana/grafana` | 3000 |

#### Step 1.4 — Bash Scripts

**`build.sh`** — Builds the Docker image:
```bash
docker build -t react-devops-app:$TAG .
```

**`deploy.sh`** — Stops old container and runs new one:
```bash
docker stop react-app && docker rm react-app
docker run -d --name react-app --restart always -p 80:80 react-devops-app:$TAG
```

---

### Phase 2 — Version Control (GitHub)

#### Step 2.1 — Repository Setup
```bash
git init
git remote add origin https://github.com/Dinesh0793/react-app-proj-3.git
git checkout -b dev
```

#### Step 2.2 — Ignore Files
- **`.gitignore`** — excludes `node_modules/`, `.env`, IDE files, `monitoring/alertmanager.yml` (contains credentials)
- **`.dockerignore`** — excludes `.git/`, `node_modules/`, `.env` from Docker image

#### Step 2.3 — Push to Dev Branch
```bash
git add .
git commit -m "Initial commit: Add React app with full DevOps setup"
git push -u origin dev
```

**Branch Strategy:**
- `dev` → Active development, pushes to `dinesh0793/dev` Docker Hub
- `master` → Production, pushes to `dinesh0793/prod` Docker Hub + deploys to EC2

---

### Phase 3 — Docker Hub Setup

Two repositories created on [hub.docker.com](https://hub.docker.com):

| Repo | Visibility | Purpose |
|------|-----------|---------|
| `dinesh0793/dev` | **Public** | Dev branch images |
| `dinesh0793/prod` | **Private** | Production images |

Image tagging strategy:
- Each build gets a numbered tag (`:1`, `:2`, `:3`...)
- `latest` tag always points to the most recent build

---

### Phase 4 — AWS EC2 Setup

#### Step 4.1 — Instance Configuration
| Setting | Value |
|---------|-------|
| AMI | Ubuntu Server 22.04 LTS |
| Instance Type | t3.micro |
| Storage | 30 GB gp3 |
| Key Pair | `.ppk` for PuTTY |

#### Step 4.2 — Security Group Rules
| Type | Protocol | Port | Source |
|------|----------|------|--------|
| HTTP | TCP | 80 | `0.0.0.0/0` (anyone can access app) |
| Custom TCP | TCP | 8080 | `0.0.0.0/0` (Jenkins UI) |
| Custom TCP | TCP | 9090 | `0.0.0.0/0` (Prometheus) |
| Custom TCP | TCP | 3000 | `0.0.0.0/0` (Grafana) |
| SSH | TCP | 22 | **My IP only** (secure admin access) |

#### Step 4.3 — EC2 Server Setup (`ec2-setup.sh`)
Automated script installs:
1. Docker CE + Docker Compose
2. Java 17 (Jenkins requirement)
3. Jenkins
4. Adds `ubuntu` and `jenkins` users to `docker` group

```bash
curl -o ec2-setup.sh https://raw.githubusercontent.com/Dinesh0793/react-app-proj-3/dev/ec2-setup.sh
bash ec2-setup.sh
```

---

### Phase 5 — Jenkins CI/CD Pipeline

#### Step 5.1 — Jenkins Setup
- Access: `http://13.232.74.74:8080`
- Plugins installed: Git, Docker Pipeline, GitHub Integration

#### Step 5.2 — Credentials Added
- **`dockerhub-credentials`** — Docker Hub username/password
- **`github-credentials`** — GitHub Personal Access Token

#### Step 5.3 — Jenkinsfile Pipeline Logic

```groovy
// dev branch → push to dinesh0793/dev
stage('Push to Dev Repo') {
    when { branch 'dev' }
    steps {
        sh "docker push dinesh0793/dev:${BUILD_NUMBER}"
    }
}

// master branch → push to dinesh0793/prod + deploy
stage('Push to Prod Repo') {
    when { branch 'master' }
    steps {
        sh "docker push dinesh0793/prod:${BUILD_NUMBER}"
    }
}

stage('Deploy to Server') {
    when { branch 'master' }
    steps { sh "./deploy.sh ${BUILD_NUMBER}" }
}
```

#### Step 5.4 — GitHub Webhook
- URL: `http://13.232.74.74:8080/github-webhook/`
- Trigger: Push event
- Effect: Jenkins auto-builds on every `git push`

#### Step 5.5 — Pipeline Flow
```
git push dev   →  Webhook  →  Jenkins builds  →  Push dinesh0793/dev:N
git push master →  Webhook  →  Jenkins builds  →  Push dinesh0793/prod:N  →  Deploy on EC2
```

---

### Phase 6 — Monitoring Stack

#### Step 6.1 — Prometheus (`monitoring/prometheus.yml`)
Scrapes metrics from:
- **`nginx` job** → `nginx-exporter:9113` (Nginx connections, requests)
- **`node` job** → `node-exporter:9100` (CPU, RAM, disk, network)
- **`prometheus`** → itself

#### Step 6.2 — Alert Rules (`monitoring/alert_rules.yml`)
| Alert | Condition | Severity |
|-------|-----------|---------|
| `NginxDown` | `up{job="nginx"} == 0` for 1 min | Critical |
| `NginxNoConnections` | `nginx_connections_active == 0` for 2 min | Warning |
| `EC2InstanceDown` | `up{job="node"} == 0` for 1 min | Critical |
| `HighCPUUsage` | CPU > 85% for 2 min | Warning |
| `HighMemoryUsage` | RAM > 90% for 2 min | Warning |

#### Step 6.3 — Grafana Dashboards
- **Dashboard ID `1860`** — Node Exporter Full (CPU, RAM, Disk, Network)
- **Dashboard ID `9614`** — Nginx Prometheus Exporter

Login: `http://13.232.74.74:3000` → `admin / admin123`

#### Step 6.4 — Alertmanager (`monitoring/alertmanager.yml`)
- Routes **Critical** alerts immediately
- Routes **Warning** alerts after grouping (5 min)
- Sends **email only when app goes DOWN** (`send_resolved: false`)

---

## 🚀 Deployment Commands (Quick Reference)

```bash
# Build image
bash build.sh

# Deploy container
bash deploy.sh

# Start full monitoring stack
docker-compose up -d

# Check running containers
docker ps

# View logs
docker logs react-app

# Stop everything
docker-compose down
```

---

## 🔗 Submission Links

| Item | URL / Value |
|------|-------------|
| GitHub Repo | https://github.com/Dinesh0793/react-app-proj-3 |
| Dev Branch | https://github.com/Dinesh0793/react-app-proj-3/tree/dev |
| Live App | http://13.232.74.74 |
| Grafana | http://13.232.74.74:3000 |
| Prometheus | http://13.232.74.74:9090 |
| Docker Dev Image | `dinesh0793/dev:latest` |
| Docker Prod Image | `dinesh0793/prod:latest` |
