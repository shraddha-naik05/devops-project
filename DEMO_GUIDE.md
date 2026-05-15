# 🎯 DevOps Microservices Project - Complete Demo Guide

## ✅ Verification & Testing Steps

### Step 1: Verify All Services Are Running

Run this command to check container status:
```bash
docker-compose ps
```

Expected output:
```
NAME       IMAGE                        STATUS
backend    my-devops-project-backend    Up (health: starting)
frontend   my-devops-project-frontend   Up
mongo      mongo:6                      Up
```

### Step 2: Check Service Logs

#### Backend Logs:
```bash
docker-compose logs backend
```
Expected: `Server running on port 3000` and `Connected to MongoDB`

#### Frontend Logs:
```bash
docker-compose logs frontend
```
Expected: Nginx server started successfully with worker processes

#### MongoDB Logs:
```bash
docker-compose logs mongo
```
Expected: MongoDB initialized and ready for connections

---

## 🧪 API Testing (Complete Workflow)

### Test 1: Check Backend Status
```powershell
Invoke-WebRequest -Uri http://localhost:3000/ -UseBasicParsing | Select-Object -ExpandProperty Content
```
Expected Response: `{"status":"Backend is running!","version":"1.0.0"}`

### Test 2: Check Backend Health
```powershell
Invoke-WebRequest -Uri http://localhost:3000/health -UseBasicParsing | Select-Object -ExpandProperty Content
```
Expected Response: `{"status":"healthy"}`

### Test 3: Get All Items (Initially Empty)
```powershell
Invoke-WebRequest -Uri http://localhost:3000/items -UseBasicParsing | Select-Object -ExpandProperty Content
```
Expected Response: `[]` (empty array)

### Test 4: Create a New Item (POST)
```powershell
$body = @{ name = "DevOps Task 1" } | ConvertTo-Json
Invoke-WebRequest -Uri http://localhost:3000/items -Method POST -Body $body -ContentType "application/json" -UseBasicParsing | Select-Object -ExpandProperty Content
```
Expected Response: 
```json
{
  "_id": "...",
  "name": "DevOps Task 1",
  "createdAt": "2026-05-14T..."
}
```

### Test 5: Create Multiple Items
```powershell
$items = @("Docker Setup", "Kubernetes Deploy", "CI/CD Pipeline", "Monitoring Stack")
foreach ($item in $items) {
    $body = @{ name = $item } | ConvertTo-Json
    Invoke-WebRequest -Uri http://localhost:3000/items -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
}
```

### Test 6: Get All Items (Populated)
```powershell
$response = Invoke-WebRequest -Uri http://localhost:3000/items -UseBasicParsing
$items = $response.Content | ConvertFrom-Json
$items | ConvertTo-Json -Depth 10
```
Expected: Array of items with timestamps

### Test 7: Delete an Item
Get an item ID from the list above, then run:
```powershell
Invoke-WebRequest -Uri "http://localhost:3000/items/{ITEM_ID}" -Method DELETE -UseBasicParsing | Select-Object -ExpandProperty Content
```
Expected Response: `{"message":"Item deleted"}`

---

## 🌐 Frontend UI Testing

### Access the Frontend
Open your browser and navigate to: **http://localhost**

### Frontend Features to Demonstrate:
1. **Status Badge** - Shows if backend is connected
2. **Add Item Form** - Text input with "Add" button
3. **Items List** - Displays all items with timestamps
4. **Delete Function** - Each item has a delete button
5. **Real-time Updates** - List updates without page refresh

### Interactive Demo Steps:
1. Load http://localhost in browser
2. Wait for "Status: ✓ Connected" message
3. Type a task name in the input field (e.g., "Setup Minikube")
4. Click "Add" button
5. See the new item appear in the list with timestamp
6. Repeat for multiple items
7. Click delete button on any item
8. Verify item is removed from the list

---

## 📦 Verify Data Persistence (MongoDB)

### Access MongoDB directly:
```bash
docker exec -it mongo mongosh
```

Inside MongoDB shell:
```javascript
use mydb
db.items.find()
```

This shows all items stored in the database.

---

## 🐳 Verify Docker Architecture

### Check Network Communication:
```bash
docker-compose logs -f
```
This shows real-time logs from all services. Try adding items in the frontend and see backend processing logs.

### Inspect Container Details:
```bash
docker inspect backend
docker inspect frontend
docker inspect mongo
```

### View Network:
```bash
docker network ls
docker network inspect my-devops-project_default
```

---

## 📊 Complete Demo Checklist for Guide

### Part 1: Architecture Overview (2-3 minutes)
- [ ] Show folder structure: `my-devops-project/`
- [ ] Explain components:
  - **Frontend**: Nginx + HTML/CSS/JS (Port 80)
  - **Backend**: Node.js Express API (Port 3000)
  - **Database**: MongoDB (Port 27017)

### Part 2: Local Development with Docker (3-5 minutes)
- [ ] Show `docker-compose.yml` configuration
- [ ] Run: `docker-compose ps` - Show running containers
- [ ] Show service logs: `docker-compose logs backend`
- [ ] Explain Docker benefits: consistency, isolation, easy deployment

### Part 3: API Testing (5 minutes)
- [ ] Test backend status: `http://localhost:3000/`
- [ ] Show health check endpoint
- [ ] Demonstrate CRUD operations:
  - GET all items
  - POST (create) new item
  - DELETE item

### Part 4: Frontend Demo (3-5 minutes)
- [ ] Open http://localhost in browser
- [ ] Show responsive UI
- [ ] Add several items interactively
- [ ] Delete an item
- [ ] Refresh page - show data persists
- [ ] Show real-time status badge

### Part 5: Data Persistence Proof (2 minutes)
- [ ] Access MongoDB: `docker exec -it mongo mongosh`
- [ ] Show data in database: `db.items.find()`
- [ ] Explain data persistence across container restarts

### Part 6: Multi-Service Communication (2 minutes)
- [ ] Show docker-compose logs streaming
- [ ] Demonstrate adding item and watching all service logs
- [ ] Explain service discovery and networking

---

## 🚀 Useful Troubleshooting Commands

### If services aren't responding:
```bash
docker-compose restart
```

### If MongoDB has issues:
```bash
docker-compose down
docker-compose up --build -d
```

### Check port availability:
```bash
netstat -ano | findstr ":3000"
netstat -ano | findstr ":80"
```

### View all logs in real-time:
```bash
docker-compose logs -f
```

---

## 📝 Key Points to Highlight in Demo

1. **Microservices Architecture**: Three independent services working together
2. **Docker Containerization**: Each service runs in isolated container
3. **Service Communication**: Backend connects to MongoDB, Frontend talks to Backend
4. **Data Persistence**: Items remain after container restart
5. **Quick Deployment**: Single `docker-compose up` command starts entire stack
6. **Scalability**: Easy to scale components independently
7. **CI/CD Ready**: GitHub Actions pipeline included (see `.github/workflows/cicd.yaml`)

---

## ⏱️ Demo Timeline (Total: ~20-25 minutes)

| Task | Time |
|------|------|
| Architecture Overview | 3 min |
| Docker Compose Explanation | 5 min |
| API Testing Walkthrough | 5 min |
| Frontend Interactive Demo | 5 min |
| Q&A + Troubleshooting | 3-7 min |

---

## 🎬 Record Demo (Optional)

To record your terminal:
```bash
# PowerShell recording (if available)
# Or take screenshots and create a presentation
```

---

## 📚 Project Files Overview

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Defines all services and networking |
| `backend/Dockerfile` | Node.js application container |
| `backend/server.js` | Express API endpoints |
| `frontend/Dockerfile` | Nginx web server |
| `frontend/app.js` | Frontend JavaScript logic |
| `k8s/` | Kubernetes deployment files (Phase 2) |

---

Good luck with your demo! 🎉
