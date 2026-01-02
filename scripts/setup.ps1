# Enterprise Setup Script for Windows (PowerShell)
# Idempotent installation with version locking

$ErrorActionPreference = "Stop"

# Determine script paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$ConfigDir = Join-Path $RepoRoot "config"
$VersionsFile = Join-Path $ConfigDir "versions.env"

# Load version locks (simple parser for env file)
$versions = @{}
if (Test-Path $VersionsFile) {
    Get-Content $VersionsFile | ForEach-Object {
        if ($_ -match '^([A-Z_]+)=(.+)$') {
            $versions[$matches[1]] = $matches[2]
        }
    }
}

$NODE_VERSION = $versions['NODE_VERSION']
$PNPM_VERSION = $versions['PNPM_VERSION']
$PYTHON_VERSION = $versions['PYTHON_VERSION']
$RUST_VERSION = $versions['RUST_VERSION']
$NVM_VERSION = $versions['NVM_VERSION']
$ALLOW_LATEST = $env:SETUP_ALLOW_LATEST -eq 'true'

# Counters
$INSTALLED = 0
$SKIPPED = 0
$FAILED = 0

# Report file
$ReportFile = Join-Path $RepoRoot "setup-report.json"

# Initialize report
$reportData = @{
    timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    os = "Windows"
    arch = [System.Environment]::Is64BitOperatingSystem ? "x64" : "x86"
    tools = @()
}

function Log-Status {
    param(
        [string]$Tool,
        [string]$Version,
        [string]$Path,
        [string]$Status
    )
    
    switch ($Status) {
        "installed" { 
            Write-Host "✅ $Tool ($Version) - INSTALLED" -ForegroundColor Green
            $script:INSTALLED++
        }
        "skipped" { 
            Write-Host "⏭️  $Tool ($Version) - SKIPPED" -ForegroundColor Yellow
            $script:SKIPPED++
        }
        "failed" { 
            Write-Host "❌ $Tool - FAILED" -ForegroundColor Red
            $script:FAILED++
        }
    }
    
    # Add to report
    $script:reportData.tools += @{
        name = $Tool
        version = $Version
        path = $Path
        status = $Status
    }
}

Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║  🚀 Enterprise Setup (Idempotent Mode)    ║" -ForegroundColor Blue
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

# Check for offline artifacts
$OFFLINE_MODE = $false
$ArtifactsDir = Join-Path $RepoRoot "artifacts"
if (Test-Path $ArtifactsDir) {
    $artifactFiles = Get-ChildItem $ArtifactsDir | Where-Object { $_.Name -ne '.gitkeep' -and $_.Name -ne 'README.md' }
    if ($artifactFiles.Count -gt 0) {
        Write-Host "📦 Offline artifacts detected - using local installers" -ForegroundColor Yellow
        $OFFLINE_MODE = $true
    }
}

# ======================
# 1. Install nvm-windows
# ======================
Write-Host "━━━ NVM (Windows) ━━━" -ForegroundColor Blue

$nvmPath = Join-Path $env:APPDATA "nvm"
if (Test-Path $nvmPath) {
    Log-Status "nvm" "installed" $nvmPath "skipped"
} else {
    Write-Host "Installing nvm-windows..."
    # Note: Actual installation requires downloading nvm-windows installer
    Write-Host "⚠️  Please install nvm-windows manually from: https://github.com/coreybutler/nvm-windows" -ForegroundColor Yellow
    Log-Status "nvm" "manual" "" "skipped"
}

# ======================
# 2. Install Node.js
# ======================
Write-Host ""
Write-Host "━━━ NODE ━━━" -ForegroundColor Blue

if (Get-Command node -ErrorAction SilentlyContinue) {
    $currentNode = (node --version) -replace 'v', ''
    Log-Status "node" $currentNode (Get-Command node).Source "skipped"
} else {
    Write-Host "⚠️  Node.js not found. Please install via nvm-windows" -ForegroundColor Yellow
    Log-Status "node" "not-found" "" "failed"
}

# ======================
# 3. Install pnpm
# ======================
Write-Host ""
Write-Host "━━━ PNPM ━━━" -ForegroundColor Blue

if (Get-Command pnpm -ErrorAction SilentlyContinue) {
    $currentPnpm = (pnpm --version)
    if ($currentPnpm -eq $PNPM_VERSION -or $ALLOW_LATEST) {
        Log-Status "pnpm" $currentPnpm (Get-Command pnpm).Source "skipped"
    } else {
        npm install -g "pnpm@$PNPM_VERSION"
        Log-Status "pnpm" $PNPM_VERSION (Get-Command pnpm).Source "installed"
    }
} else {
    if ($ALLOW_LATEST) {
        npm install -g pnpm
    } else {
        npm install -g "pnpm@$PNPM_VERSION"
    }
    $pnpmVer = (pnpm --version)
    Log-Status "pnpm" $pnpmVer (Get-Command pnpm).Source "installed"
}

# ======================
# 4. Install Python/Miniconda
# ======================
Write-Host ""
Write-Host "━━━ CONDA ━━━" -ForegroundColor Blue

$condaPath = Join-Path $env:USERPROFILE "miniconda3"
if (Test-Path $condaPath) {
    $condaExe = Join-Path $condaPath "Scripts\conda.exe"
    if (Test-Path $condaExe) {
        $condaVer = (& $condaExe --version) -replace 'conda ', ''
        Log-Status "conda" $condaVer $condaPath "skipped"
    }
} else {
    Write-Host "⚠️  Miniconda not found. Download from: https://docs.conda.io/en/latest/miniconda.html" -ForegroundColor Yellow
    Log-Status "conda" "not-found" "" "failed"
}

# ======================
# 5. Install uv
# ======================
Write-Host ""
Write-Host "━━━ UV ━━━" -ForegroundColor Blue

if (Get-Command uv -ErrorAction SilentlyContinue) {
    $uvVer = (uv --version) -replace 'uv ', ''
    Log-Status "uv" $uvVer (Get-Command uv).Source "skipped"
} else {
    Write-Host "Installing uv..."
    irm https://astral.sh/uv/install.ps1 | iex
    $uvVer = (uv --version) -replace 'uv ', ''
    Log-Status "uv" $uvVer "$env:USERPROFILE\.cargo\bin\uv.exe" "installed"
}

# ======================
# 6. Install Rust
# ======================
Write-Host ""
Write-Host "━━━ RUST ━━━" -ForegroundColor Blue

if (Get-Command rustc -ErrorAction SilentlyContinue) {
    $rustVer = (rustc --version) -replace 'rustc ', '' -replace ' \(.*\)', ''
    Log-Status "rust" $rustVer "$env:USERPROFILE\.cargo" "skipped"
} else {
    Write-Host "⚠️  Rust not found. Download from: https://rustup.rs" -ForegroundColor Yellow
    Log-Status "rust" "not-found" "" "failed"
}

# ======================
# 7. Generate env.d files
# ======================
Write-Host ""
Write-Host "━━━ ENV SETUP ━━━" -ForegroundColor Blue

$envDir = Join-Path $RepoRoot "env.d"
$toolsEnv = Join-Path $envDir "10-tools.env"

$envContent = @"
# Auto-generated by setup.ps1 on $(Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
# DO NOT EDIT MANUALLY

# Note: PowerShell environment setup
`$env:PATH = "$env:USERPROFILE\.cargo\bin;" + `$env:PATH
`$env:PATH = "$env:USERPROFILE\miniconda3\Scripts;" + `$env:PATH
"@

Set-Content -Path $toolsEnv -Value $envContent
Write-Host "✅ env.d/10-tools.env generated" -ForegroundColor Green

# ======================
# 8. Generate MCP Context
# ======================
Write-Host ""
Write-Host "━━━ MCP CONTEXT ━━━" -ForegroundColor Blue

$mcpDir = Join-Path $RepoRoot ".mcp"
if (!(Test-Path $mcpDir)) {
    New-Item -ItemType Directory -Path $mcpDir | Out-Null
}

$nodeVer = if (Get-Command node -ErrorAction SilentlyContinue) { (node --version) -replace 'v', '' } else { "not-installed" }
$nodePath = if (Get-Command node -ErrorAction SilentlyContinue) { (Get-Command node).Source } else { "not-found" }
$pythonVer = "not-installed"
$rustVer = if (Get-Command rustc -ErrorAction SilentlyContinue) { (rustc --version) -replace 'rustc ', '' -replace ' \(.*\)', '' } else { "not-installed" }

$mcpContext = @{
    repository = "eyshoit-commits/setup"
    os = "Windows"
    arch = [System.Environment]::Is64BitOperatingSystem ? "x64" : "x86"
    shell = "PowerShell"
    toolchain = @{
        node = @{
            version = $nodeVer
            manager = "nvm"
            path = $nodePath
        }
        python = @{
            version = $pythonVer
            manager = "conda"
            path = "$env:USERPROFILE\miniconda3"
        }
        rust = @{
            version = $rustVer
            path = "$env:USERPROFILE\.cargo"
        }
    }
    roles = @("backend", "frontend", "devops", "testing")
    agents = @("main-orchestrator", "backend-agent", "frontend-agent", "devops-agent", "testing-agent")
    setup_timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    setup_status = "success"
}

$mcpContext | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $mcpDir "context.json")
Write-Host "✅ .mcp/context.json generated" -ForegroundColor Green

# ======================
# 9. Run Smoke Tests
# ======================
Write-Host ""
Write-Host "━━━ SMOKE TESTS ━━━" -ForegroundColor Blue

$smokeTest = Join-Path $ScriptDir "smoke-test.ps1"
if (Test-Path $smokeTest) {
    & $smokeTest
} else {
    Write-Host "⚠️  smoke-test.ps1 not found, skipping smoke tests" -ForegroundColor Yellow
}

# ======================
# 10. Finalize Report
# ======================
$reportData.summary = @{
    installed = $INSTALLED
    skipped = $SKIPPED
    failed = $FAILED
    total = $INSTALLED + $SKIPPED + $FAILED
}

$reportData | ConvertTo-Json -Depth 10 | Set-Content $ReportFile

# ======================
# Summary
# ======================
Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║            SETUP SUMMARY                   ║" -ForegroundColor Blue
Write-Host "╠════════════════════════════════════════════╣" -ForegroundColor Blue
Write-Host "║ ✅ INSTALLED: $INSTALLED" -ForegroundColor Blue
Write-Host "║ ⏭️  SKIPPED:   $SKIPPED" -ForegroundColor Blue
Write-Host "║ ❌ FAILED:    $FAILED" -ForegroundColor Blue
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""
Write-Host "📊 Full report: $ReportFile" -ForegroundColor Green
Write-Host "🤖 MCP Context: .mcp/context.json" -ForegroundColor Green
Write-Host ""

if ($FAILED -gt 0) {
    exit 1
}
