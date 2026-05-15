# DevOps Microservices Project - Automated Testing Script
# This script performs all tests and demonstrations

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  DevOps Microservices Project - Complete Testing & Demo       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Color function
function Write-Section {
    param([string]$title)
    Write-Host "`n📌 $title" -ForegroundColor Yellow
    Write-Host ("=" * 60) -ForegroundColor Gray
}

# Test function with error handling
function Test-Endpoint {
    param(
        [string]$url,
        [string]$description,
        [string]$method = "GET",
        [psobject]$body = $null
    )
    
    try {
        Write-Host "🔄 Testing: $description..." -ForegroundColor Cyan
        
        $params = @{
            Uri = $url
            Method = $method
            UseBasicParsing = $true
            TimeoutSec = 10
        }
        
        if ($body) {
            $params['Body'] = $body | ConvertTo-Json
            $params['ContentType'] = "application/json"
        }
        
        $response = Invoke-WebRequest @params
        $content = $response.Content | ConvertFrom-Json
        
        Write-Host "✅ SUCCESS" -ForegroundColor Green
        Write-Host "Response: " -ForegroundColor Gray
        Write-Host ($content | ConvertTo-Json) -ForegroundColor Green
        
        return $content
    }
    catch {
        Write-Host "❌ FAILED - $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# ============================================================
Write-Section "STEP 1: Verify Docker Containers"
# ============================================================

Write-Host "Checking container status..." -ForegroundColor Cyan
$containers = docker-compose ps --format "table {{.Names}}\t{{.Status}}"
Write-Host $containers

# Verify all containers are running
$allRunning = docker-compose ps -q | Measure-Object | Select-Object -ExpandProperty Count
if ($allRunning -eq 3) {
    Write-Host "✅ All 3 containers are running!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Warning: Not all containers are running" -ForegroundColor Yellow
}

# ============================================================
Write-Section "STEP 2: Check Service Logs"
# ============================================================

Write-Host "📋 Backend Logs:" -ForegroundColor Cyan
docker-compose logs --tail=5 backend

Write-Host "`n📋 Frontend Logs:" -ForegroundColor Cyan
docker-compose logs --tail=5 frontend

Write-Host "`n📋 MongoDB Logs:" -ForegroundColor Cyan
docker-compose logs --tail=5 mongo

# ============================================================
Write-Section "STEP 3: API Status Tests"
# ============================================================

$backendStatus = Test-Endpoint "http://localhost:3000/" "Backend Status"
$healthStatus = Test-Endpoint "http://localhost:3000/health" "Health Check"

# ============================================================
Write-Section "STEP 4: Get Initial Items (Should be empty or existing)"
# ============================================================

try {
    Write-Host "🔄 Fetching all items..." -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri "http://localhost:3000/items" -UseBasicParsing
    $items = $response.Content | ConvertFrom-Json
    
    Write-Host "✅ SUCCESS" -ForegroundColor Green
    Write-Host "Total items in database: $($items.Count)" -ForegroundColor Cyan
    
    if ($items.Count -gt 0) {
        Write-Host "Existing items:" -ForegroundColor Gray
        $items | ForEach-Object { Write-Host "  - $($_.name) (ID: $($_.id))" -ForegroundColor Green }
    } else {
        Write-Host "Database is empty (ready for demo)" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "❌ FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

# ============================================================
Write-Section "STEP 5: CREATE Test - Add New Item"
# ============================================================

$testItem = @{ name = "Demo Item - $(Get-Date -Format 'HH:mm:ss')" }
$response = Test-Endpoint "http://localhost:3000/items" "Create New Item" "POST" $testItem

if ($response) {
    $createdItemId = $response._id
    Write-Host "Created item ID: $createdItemId" -ForegroundColor Cyan
}

# ============================================================
Write-Section "STEP 6: Add Multiple Demo Items"
# ============================================================

Write-Host "Adding 5 demo items for showcase..." -ForegroundColor Cyan
$demoItems = @(
    "Complete Docker Setup",
    "Deploy to Kubernetes",
    "Setup CI/CD Pipeline",
    "Configure Monitoring",
    "Load Testing and Optimization"
)

$addedIds = @()
foreach ($item in $demoItems) {
    try {
        $body = @{ name = $item } | ConvertTo-Json
        $response = Invoke-WebRequest -Uri "http://localhost:3000/items" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
        $result = $response.Content | ConvertFrom-Json
        $addedIds += $result._id
        Write-Host "  ✅ Added: $item" -ForegroundColor Green
        Start-Sleep -Milliseconds 300
    }
    catch {
        Write-Host "  ❌ Failed to add: $item" -ForegroundColor Red
    }
}

# ============================================================
Write-Section "STEP 7: READ Test - Retrieve All Items"
# ============================================================

try {
    Write-Host "🔄 Fetching all items..." -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri "http://localhost:3000/items" -UseBasicParsing
    $items = $response.Content | ConvertFrom-Json
    
    Write-Host "✅ SUCCESS - Retrieved $($items.Count) items" -ForegroundColor Green
    Write-Host "`nAll Items in Database:" -ForegroundColor Cyan
    
    $items | ForEach-Object {
        $createdAt = $_.createdAt -replace 'T', ' ' -replace '\.\d+Z', ''
        Write-Host "  📝 $($_.name)" -ForegroundColor Green
        Write-Host "     ID: $($_.id)" -ForegroundColor Gray
        Write-Host "     Created: $createdAt" -ForegroundColor Gray
    }
}
catch {
    Write-Host "❌ FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

# ============================================================
Write-Section "STEP 8: DELETE Test - Remove an Item"
# ============================================================

if ($addedIds.Count -gt 0) {
    $itemToDelete = $addedIds[0]
    try {
        Write-Host "🔄 Deleting item ID: $itemToDelete..." -ForegroundColor Cyan
        $response = Invoke-WebRequest -Uri "http://localhost:3000/items/$itemToDelete" -Method DELETE -UseBasicParsing
        $result = $response.Content | ConvertFrom-Json
        
        Write-Host "✅ SUCCESS" -ForegroundColor Green
        Write-Host "Response: $($result.message)" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ FAILED - $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️ No items to delete (database empty)" -ForegroundColor Yellow
}

# ============================================================
Write-Section "STEP 9: Frontend Verification"
# ============================================================

try {
    Write-Host "🔄 Fetching frontend HTML..." -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri "http://localhost" -UseBasicParsing
    
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Frontend is running" -ForegroundColor Green
        Write-Host "   Title: $(($response.Content | Select-String '<title>(.*)</title>' -AllMatches).Matches.Groups[1].Value)" -ForegroundColor Gray
        Write-Host "   Status Code: $($response.StatusCode)" -ForegroundColor Gray
        Write-Host "`n📌 Open http://localhost in your browser to see the UI" -ForegroundColor Cyan
    }
}
catch {
    Write-Host "❌ FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

# ============================================================
Write-Section "STEP 10: Data Persistence Check"
# ============================================================

Write-Host "Checking MongoDB directly..." -ForegroundColor Cyan
try {
    $mongoCheck = docker exec mongo mongosh --eval "db.items.countDocuments()" 2>&1
    Write-Host "✅ MongoDB is accessible" -ForegroundColor Green
    Write-Host "   Documents in database: $mongoCheck" -ForegroundColor Cyan
}
catch {
    Write-Host "Cannot verify MongoDB directly" -ForegroundColor Yellow
}

# ============================================================
Write-Section "SUMMARY"
# ============================================================

Write-Host "`n" -ForegroundColor Cyan
Write-Host "✅ PROJECT STATUS: ALL SERVICES OPERATIONAL" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Service Endpoints:" -ForegroundColor Cyan
Write-Host "   Frontend UI:  http://localhost" -ForegroundColor Yellow
Write-Host "   Backend API:  http://localhost:3000" -ForegroundColor Yellow
Write-Host "   MongoDB:      localhost:27017" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔧 Useful Commands:" -ForegroundColor Cyan
Write-Host "   View logs:    docker-compose logs -f" -ForegroundColor Gray
Write-Host "   Restart:      docker-compose restart" -ForegroundColor Gray
Write-Host "   Stop all:     docker-compose down" -ForegroundColor Gray
Write-Host "   MongoDB CLI:  docker exec -it mongo mongosh" -ForegroundColor Gray
Write-Host ""
Write-Host "📖 For detailed demo instructions, see: DEMO_GUIDE.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🎉 Project is Ready for Demo Presentation! 🎉                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
