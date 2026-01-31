# Test complet du devcontainer
# Usage: .\test-devcontainer.ps1

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "[TEST] DevContainer Claude Code Proxy" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Aller dans le dossier devcontainer
Set-Location "$PSScriptRoot\.devcontainer"

try {
    # Build
    Write-Host "[BUILD] Construction de l'image Docker..." -ForegroundColor Yellow
    docker-compose build --no-cache
    if ($LASTEXITCODE -ne 0) { throw "Build failed" }
    Write-Host "[OK] Build reussi" -ForegroundColor Green
    Write-Host ""

    # Start
    Write-Host "[START] Demarrage du container..." -ForegroundColor Yellow
    docker-compose up -d
    if ($LASTEXITCODE -ne 0) { throw "Start failed" }
    Start-Sleep -Seconds 3
    Write-Host "[OK] Container demarre" -ForegroundColor Green
    Write-Host ""

    # Start proxy
    Write-Host "[PROXY] Demarrage du proxy..." -ForegroundColor Yellow
    docker exec devcontainer-devcontainer-1 bash -c "start-proxy"
    Start-Sleep -Seconds 2
    Write-Host ""

    # Run tests
    Write-Host "[TEST] Execution des tests..." -ForegroundColor Yellow
    docker exec devcontainer-devcontainer-1 bash -c "test-proxy"
    $testResult = $LASTEXITCODE
    Write-Host ""

    if ($testResult -eq 0) {
        Write-Host "[OK] Tous les tests ont reussi!" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Certains tests ont echoue" -ForegroundColor Red
    }

} finally {
    # Cleanup
    Write-Host ""
    Write-Host "[CLEANUP] Nettoyage..." -ForegroundColor Yellow
    docker-compose down -v 2>$null
    Write-Host "[OK] Container supprime" -ForegroundColor Green
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "[DONE] Test termine" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
