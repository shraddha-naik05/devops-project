# 🚀 DevOps Microservices Project
**NIE – BCS657D | Anjana Suresh Kumar & Bharti S | 6th Sem CSE-A**

---

## 📁 Project Structure

```
my-devops-project/
├── frontend/           # HTML/CSS/JS + Nginx
│   ├── index.html
│   ├── style.css
│   ├── app.js
│   ├── nginx.conf
│   └── Dockerfile
├── backend/            # Node.js + Express + MongoDB
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
├── k8s/                # Kubernetes manifests
│   ├── mongo.yaml
│   ├── backend.yaml
│   └── frontend.yaml
├── .github/
│   └── workflows/
│       └── cicd.yaml   # GitHub Actions
└── docker-compose.yml  # Local testing
```

---

## ⚙️ Phase 1: Local Testing with Docker Compose

```bash
# Build and start all services
docker compose up --build

# Run in background
docker compose up --build -d

# Stop everything
docker compose down
```

Open in browser:
- Frontend → http://localhost
- Backend  → http://localhost:3000

---

## ☸️ Phase 2: Deploy on Kubernetes (Minikube)

### Step 1 – Replace image names
Open `k8s/backend.yaml` and `k8s/frontend.yaml` and replace:
```
YOUR_DOCKERHUB_USERNAME
```
with your actual DockerHub username.

### Step 2 – Push images to DockerHub
```bash
docker build -t YOUR_DOCKERHUB_USERNAME/backend:latest ./backend
docker push YOUR_DOCKERHUB_USERNAME/backend:latest

docker build -t YOUR_DOCKERHUB_USERNAME/frontend:latest ./frontend
docker push YOUR_DOCKERHUB_USERNAME/frontend:latest
```

### Step 3 – Start Minikube and deploy
```bash
minikube start

kubectl apply -f k8s/

# Check pods are running
kubectl get pods

# Check services
kubectl get services
```

### Step 4 – Access the app
```bash
minikube service frontend --url
minikube service backend --url
```

---

## 🔁 Phase 3: GitHub Actions CI/CD

### Step 1 – Push code to GitHub
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

### Step 2 – Add DockerHub secrets in GitHub
Go to: **GitHub Repo → Settings → Secrets → Actions → New repository secret**

| Secret Name       | Value                    |
|-------------------|--------------------------|
| DOCKER_USERNAME   | Your DockerHub username  |
| DOCKER_PASSWORD   | Your DockerHub password  |

### Step 3 – Every git push triggers the pipeline automatically ✅

---

## 🛠️ Useful Commands

```bash
# View logs
docker compose logs backend
kubectl logs deployment/backend

# Scale manually
kubectl scale deployment backend --replicas=3

# Delete all k8s resources
kubectl delete -f k8s/

# Minikube dashboard
minikube dashboard
```
