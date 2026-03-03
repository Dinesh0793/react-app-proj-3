# React App DevOps Project — CI/CD Pipeline

## 🚀 Live Deployment
- **Deployed App URL:** http://13.232.74.74
- **Grafana Dashboard:** http://13.232.74.74:3000
- **Prometheus:** http://13.232.74.74:9090

## 🐳 Docker Hub Images
- **Dev Image (Public):** `dinesh0793/dev:latest`
- **Prod Image (Private):** `dinesh0793/prod:latest`

## 📦 Tech Stack
| Layer | Tool |
|-------|------|
| App | React (pre-built, served via Nginx) |
| Containerization | Docker + Docker Compose |
| CI/CD | Jenkins (Multibranch Pipeline) |
| Registry | Docker Hub (`dev` public, `prod` private) |
| Cloud | AWS EC2 t3.micro (Ubuntu 22.04) |
| Monitoring | Prometheus + Grafana + Alertmanager |

## 🔁 CI/CD Flow
```
git push dev   → Jenkins → Build image → Push to dinesh0793/dev
git merge master → Jenkins → Push to dinesh0793/prod → Deploy on EC2
```

## 🗂️ Project Structure
```
devops-build-main/
├── build/              # Pre-built React app
├── monitoring/
│   ├── prometheus.yml
│   ├── alert_rules.yml
│   └── grafana/
├── Dockerfile
├── nginx.conf
├── docker-compose.yml
├── build.sh
├── deploy.sh
├── Jenkinsfile
├── ec2-setup.sh
├── .gitignore
└── .dockerignore
```

## 📸 Screenshots
See the `screenshots/` folder for:
- Jenkins login page, configuration, and build execution
- AWS EC2 console and Security Group configuration
- Docker Hub repos with image tags
- Deployed application
- Grafana monitoring dashboard
- Prometheus targets health status

## ⚙️ AWS Security Group
| Rule | Port | Source |
|------|------|--------|
| HTTP | 80 | 0.0.0.0/0 (all) |
| Jenkins | 8080 | 0.0.0.0/0 |
| Prometheus | 9090 | 0.0.0.0/0 |
| Grafana | 3000 | 0.0.0.0/0 |
| SSH | 22 | My IP only |
