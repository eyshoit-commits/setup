# Smoke Test Script for Windows (PowerShell)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

$FAILED = 0

Write-Host "Running smoke tests..." 
Write-Host ""

# Node
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVer = node --version
    Write-Host "✅ Node smoke test passed ($nodeVer)" -ForegroundColor Green
} else {
    Write-Host "❌ Node smoke test FAILED" -ForegroundColor Red
    $FAILED++
}

# Python (via uvx)
if ((Get-Command uvx -ErrorAction SilentlyContinue) -and (uvx ruff --version 2>$null)) {
    $ruffVer = uvx ruff --version
    Write-Host "✅ Python/uvx smoke test passed ($ruffVer)" -ForegroundColor Green
} else {
    Write-Host "❌ Python/uvx smoke test FAILED" -ForegroundColor Red
    $FAILED++
}

# Rust
if (Get-Command cargo -ErrorAction SilentlyContinue) {
    $cargoVer = cargo --version
    Write-Host "✅ Rust smoke test passed ($cargoVer)" -ForegroundColor Green
} else {
    Write-Host "❌ Rust smoke test FAILED" -ForegroundColor Red
    $FAILED++
}

# pnpm
if (Get-Command pnpm -ErrorAction SilentlyContinue) {
    try {
        pnpm store path | Out-Null
        $pnpmVer = pnpm --version
        Write-Host "✅ pnpm smoke test passed ($pnpmVer)" -ForegroundColor Green
    } catch {
        Write-Host "❌ pnpm smoke test FAILED" -ForegroundColor Red
        $FAILED++
    }
} else {
    Write-Host "❌ pnpm smoke test FAILED" -ForegroundColor Red
    $FAILED++
}

# Update report if it exists
$ReportFile = Join-Path $RepoRoot "setup-report.json"
if (Test-Path $ReportFile) {
    $report = Get-Content $ReportFile | ConvertFrom-Json
    
    $report | Add-Member -NotePropertyName smoke_tests -NotePropertyValue @{
        node = if (Get-Command node -ErrorAction SilentlyContinue) { "passed" } else { "failed" }
        python = if ((Get-Command uvx -ErrorAction SilentlyContinue) -and (uvx ruff --version 2>$null)) { "passed" } else { "failed" }
        rust = if (Get-Command cargo -ErrorAction SilentlyContinue) { "passed" } else { "failed" }
        pnpm = if (Get-Command pnpm -ErrorAction SilentlyContinue) { "passed" } else { "failed" }
    } -Force
    
    $report | ConvertTo-Json -Depth 10 | Set-Content $ReportFile
}

Write-Host ""
if ($FAILED -eq 0) {
    Write-Host "✅ All smoke tests passed!" -ForegroundColor Green
} else {
    Write-Host "❌ $FAILED smoke test(s) failed" -ForegroundColor Red
}

exit $FAILED
