$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location "$repoRoot\api"

Write-Host "[1/3] Instalando dependencias..." -ForegroundColor Cyan
npm ci

Write-Host "[2/3] Ejecutando pruebas y cobertura..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force "reports" | Out-Null
npm run test:ci

Write-Host "[3/3] Generando tablero del agente..." -ForegroundColor Cyan
$env:CHECKOUT_OUTCOME = "success"
$env:NODE_OUTCOME = "success"
$env:INSTALL_OUTCOME = "success"
$env:TEST_OUTCOME = "success"
$env:SONAR_OUTCOME = "success"

Set-Location $repoRoot
node ".\ci\evacua-quality-agent.cjs"

$dashboard = "$repoRoot\reports\quality-agent\index.html"
Write-Host "Tablero creado: $dashboard" -ForegroundColor Green
Start-Process $dashboard
