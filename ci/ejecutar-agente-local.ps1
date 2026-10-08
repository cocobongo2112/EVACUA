$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$dashboard = "$repoRoot\reports\quality-agent\index.html"

$env:CHECKOUT_OUTCOME = "success"
$env:NODE_OUTCOME = "success"
$env:INSTALL_OUTCOME = "unknown"
$env:TEST_OUTCOME = "unknown"
$env:SONAR_OUTCOME = "skipped"

function Finish-Agent([int]$exitCode) {
    Set-Location $repoRoot
    node ".\ci\evacua-quality-agent.cjs"
    Write-Host "Tablero creado: $dashboard" -ForegroundColor Green
    Start-Process $dashboard
    exit $exitCode
}

Set-Location "$repoRoot\api"

Write-Host "[1/3] Instalando dependencias..." -ForegroundColor Cyan
npm ci
if ($LASTEXITCODE -ne 0) {
    $env:INSTALL_OUTCOME = "failure"
    $env:TEST_OUTCOME = "skipped"
    Write-Host "No fue posible instalar las dependencias. El agente mostrará el diagnóstico." -ForegroundColor Red
    Finish-Agent 1
}
$env:INSTALL_OUTCOME = "success"

Write-Host "[2/3] Ejecutando pruebas y cobertura..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force "reports" | Out-Null
npm run test:ci
if ($LASTEXITCODE -ne 0) {
    $env:TEST_OUTCOME = "failure"
    Write-Host "Las pruebas fallaron. El agente mostrará el diagnóstico." -ForegroundColor Red
    Finish-Agent 1
}
$env:TEST_OUTCOME = "success"

Write-Host "[3/3] Generando tablero del agente..." -ForegroundColor Cyan
Write-Host "SonarQube se validará dentro de GitHub Actions." -ForegroundColor Yellow
Finish-Agent 0
