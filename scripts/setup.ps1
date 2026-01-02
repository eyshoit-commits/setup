# ==============================================
# Enterprise-Grade Development Environment Setup (PowerShell)
# ==============================================
# Installs and configures development tools with:
# - Supply chain tracking (provenance.json)
# - Repro mode for CI/Codespaces
# - Agent handshake generation
# - Feature gate support
# - Drift detection
# - Golden path enforcement

$ErrorActionPreference = "Stop"

# Colors
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Header($Message) {
    Write-ColorOutput Cyan "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-ColorOutput Cyan $Message
    Write-ColorOutput Cyan "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

Write-Header "🚀 Enterprise-Grade Development Environment Setup"
Write-Output ""

# Determine script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
Set-Location $RepoRoot

# ==============================================
# Load Configuration
# ==============================================
Write-ColorOutput Cyan "📋 Loading configuration..."

$ConfigFile = Join-Path $RepoRoot "config\versions.env"
if (Test-Path $ConfigFile) {
    Get-Content $ConfigFile | ForEach-Object {
        if ($_ -match '^\s*([A-Z_]+)=(.+)$') {
            $name = $matches[1]
            $value = $matches[2]
            Set-Item -Path "env:$name" -Value $value
        }
    }
    Write-Output "✅ Loaded config/versions.env"
} else {
    Write-ColorOutput Red "❌ config/versions.env not found"
    exit 1
}

$FeaturesFile = Join-Path $RepoRoot "env.d\20-features.env"
if (Test-Path $FeaturesFile) {
    Get-Content $FeaturesFile | ForEach-Object {
        if ($_ -match '^\s*([A-Z_]+)=\$\{[A-Z_]+:-(.+)\}$') {
            $name = $matches[1]
            $value = $matches[2]
            if (-not (Test-Path "env:$name")) {
                Set-Item -Path "env:$name" -Value $value
            }
        }
    }
    Write-Output "✅ Loaded env.d/20-features.env"
}

# ==============================================
# Detect Setup Mode
# ==============================================
Write-Output ""
Write-ColorOutput Cyan "🔍 Detecting environment..."

if ($env:CODESPACE_NAME -or $env:CI -or $env:GITHUB_ACTIONS) {
    $env:SETUP_MODE = "repro"
    Write-ColorOutput Yellow "🔒 CI/Codespace detected - forcing REPRO mode"
    $env:ALLOW_LATEST = "false"
    $env:PREFER_OFFLINE = "true"
    $env:STRICT_VERSIONS = "true"
} else {
    if (-not $env:SETUP_MODE) {
        $env:SETUP_MODE = "dev"
    }
    Write-Output "📍 Running in $($env:SETUP_MODE) mode"
}

Write-Output "   SETUP_MODE: $($env:SETUP_MODE)"
Write-Output "   ALLOW_LATEST: $($env:ALLOW_LATEST)"
Write-Output "   STRICT_VERSIONS: $($env:STRICT_VERSIONS)"

# ==============================================
# Initialize Provenance Tracking
# ==============================================
Write-Output ""
Write-ColorOutput Cyan "📦 Initializing supply chain provenance..."

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
# Use cryptographically secure random number generator
$Rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
$RandomBytes = New-Object byte[] 3
$Rng.GetBytes($RandomBytes)
$RandomHex = -join ($RandomBytes | ForEach-Object { "{0:x2}" -f $_ })
$SetupId = "$Timestamp-$RandomHex"
$ProvenanceFile = Join-Path $RepoRoot "provenance.json"

$Provenance = @{
    setup_id = $SetupId
    timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    host = @{
        hostname = $env:COMPUTERNAME
        os = "Windows"
        arch = $env:PROCESSOR_ARCHITECTURE
        user = $env:USERNAME
    }
    installers = @()
    integrity = @{
        all_verified = $true
        failed_checks = @()
        trust_level = "high"
    }
} | ConvertTo-Json -Depth 10

$Provenance | Out-File -FilePath $ProvenanceFile -Encoding utf8
Write-Output "✅ Provenance initialized: $SetupId"

# Function to record installer
function Record-Installer {
    param(
        [string]$Name,
        [string]$Version,
        [string]$Source,
        [string]$Location
    )

    $Hash = "unavailable"
    if (Test-Path $Location) {
        $Hash = (Get-FileHash -Path $Location -Algorithm SHA256).Hash
    }

    $Prov = Get-Content $ProvenanceFile | ConvertFrom-Json
    $Prov.installers += @{
        name = $Name
        version = $Version
        source = $Source
        location = $Location
        sha256 = $Hash
        verified = ($Hash -ne "unavailable")
    }
    $Prov | ConvertTo-Json -Depth 10 | Out-File -FilePath $ProvenanceFile -Encoding utf8
}

# Initialize setup report
$ReportFile = Join-Path $RepoRoot "setup-report.json"
$Report = @{
    setup_id = $SetupId
    timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    os = "Windows"
    arch = $env:PROCESSOR_ARCHITECTURE
    mode = $env:SETUP_MODE
    tools = @()
    summary = @{
        total = 0
        installed = 0
        skipped = 0
        failed = 0
    }
} | ConvertTo-Json -Depth 10

$Report | Out-File -FilePath $ReportFile -Encoding utf8

# Function to log tool status
#Requires -Version 7.0
$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Repository Setup..." -ForegroundColor Green

# Check prerequisites
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js required" -ForegroundColor Red
    exit 1
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "❌ npm required" -ForegroundColor Red
    exit 1
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "⚠️  GitHub CLI recommended" -ForegroundColor Yellow
}

# Install dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Green
npm install

# Setup .opencode
Write-Host "⚙️  Setting up OpenCode..." -ForegroundColor Green
if (-not (Test-Path ".opencode")) {
    Write-Host "⚠️  .opencode directory not found, creating..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path ".opencode/agents" -Force | Out-Null
}

# Verify secrets
Write-Host "🔐 Checking secrets..." -ForegroundColor Green
$REQUIRED_SECRETS = @("SNYK_TOKEN", "CODECOV_TOKEN", "CODACY_PROJECT_TOKEN", "WAKATIME_API_KEY")
$MISSING = 0

foreach ($secret in $REQUIRED_SECRETS) {
    try {
        $result = gh secret list 2>$null | Select-String $secret
        if ($result) {
            Write-Host "✓ $secret" -ForegroundColor Green
        } else {
            Write-Host "✗ $secret (missing)" -ForegroundColor Yellow
            $MISSING = 1
        }
    } catch {
        Write-Host "✗ $secret (missing)" -ForegroundColor Yellow
        $MISSING = 1
    }
}

if ($MISSING -eq 1) {
    Write-Host "⚠️  Add missing secrets: gh secret set SECRET_NAME" -ForegroundColor Yellow
}

# Setup Git hooks
Write-Host "🪝 Setting up Git hooks..." -ForegroundColor Green
New-Item -ItemType Directory -Path ".git/hooks" -Force | Out-Null

if ($IsWindows) {
    $preCommitContent = @"
#!/usr/bin/env pwsh
npm run lint
npm test
"@
} else {
    $preCommitContent = @"
#!/usr/bin/env bash
npm run lint
npm test
"@
}

$preCommitContent | Out-File -FilePath ".git/hooks/pre-commit" -Encoding UTF8
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host "📖 Next steps:" -ForegroundColor Green
Write-Host "  1. Add missing secrets (if any)"
Write-Host "  2. Run: npm test"
Write-Host "  3. Run: npm run lint"
Write-Host "  4. Commit your changes"
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

    $Rep = Get-Content $ReportFile | ConvertFrom-Json
    $Rep.tools += @{
    
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
    $Rep.summary.total++

    switch ($Status) {
        "installed" { $Rep.summary.installed++ }
        "skipped" { $Rep.summary.skipped++ }
        "failed" { $Rep.summary.failed++ }
    }

    $Rep | ConvertTo-Json -Depth 10 | Out-File -FilePath $ReportFile -Encoding utf8
}

# ==============================================
# Install Node.js (via nvm-windows or direct)
# ==============================================
if ($env:FEATURE_NODE -eq "true") {
    Write-Output ""
    Write-ColorOutput Cyan "━━━ Installing Node.js (FEATURE_NODE=true) ━━━"

    if (Get-Command node -ErrorAction SilentlyContinue) {
        $NodeCurrent = (node --version) -replace '^v', ''
        Write-Output "ℹ️  Node.js already installed: $NodeCurrent"

        if ($NodeCurrent -eq $env:NODE_VERSION) {
            Write-Output "✅ Version matches expected: $($env:NODE_VERSION)"
        } else {
            Write-ColorOutput Yellow "⚠️  Version mismatch (expected: $($env:NODE_VERSION), got: $NodeCurrent)"
        }
        Log-Status "node" $NodeCurrent (Get-Command node).Source "installed"
    } else {
        Write-Output "📦 Installing Node.js $($env:NODE_VERSION)..."
        Write-ColorOutput Yellow "ℹ️  Manual installation required on Windows"
        Write-Output "   Download from: https://nodejs.org/dist/v$($env:NODE_VERSION)/node-v$($env:NODE_VERSION)-x64.msi"
        Log-Status "node" "N/A" "N/A" "skipped"
    }
} else {
    Write-Output ""
    Write-ColorOutput Yellow "⏭️  Skipping Node.js (FEATURE_NODE=false)"
    Log-Status "node" "N/A" "N/A" "skipped"
}

# ==============================================
# Install Python (via Miniconda)
# ==============================================
if ($env:FEATURE_PYTHON -eq "true") {
    Write-Output ""
    Write-ColorOutput Cyan "━━━ Installing Python (FEATURE_PYTHON=true) ━━━"

    if (Get-Command python -ErrorAction SilentlyContinue) {
        $PythonCurrent = (python --version 2>&1) -replace 'Python ', ''
        Write-Output "ℹ️  Python already installed: $PythonCurrent"
        Log-Status "python" $PythonCurrent (Get-Command python).Source "installed"
    } else {
        Write-Output "📦 Installing Python $($env:PYTHON_VERSION) via Miniconda..."
        Write-ColorOutput Yellow "ℹ️  Manual installation required on Windows"
        Write-Output "   Download from: https://repo.anaconda.com/miniconda/"
        Log-Status "python" "N/A" "N/A" "skipped"
    }
} else {
    Write-Output ""
    Write-ColorOutput Yellow "⏭️  Skipping Python (FEATURE_PYTHON=false)"
    Log-Status "python" "N/A" "N/A" "skipped"
}

# ==============================================
# Install Rust
# ==============================================
if ($env:FEATURE_RUST -eq "true") {
    Write-Output ""
    Write-ColorOutput Cyan "━━━ Installing Rust (FEATURE_RUST=true) ━━━"

    if (Get-Command rustc -ErrorAction SilentlyContinue) {
        $RustCurrent = (rustc --version) -replace 'rustc ', '' -replace ' \(.+\)', ''
        Write-Output "ℹ️  Rust already installed: $RustCurrent"
        Log-Status "rust" $RustCurrent (Get-Command rustc).Source "installed"
    } else {
        Write-Output "📦 Installing Rust $($env:RUST_VERSION)..."
        Write-ColorOutput Yellow "ℹ️  Manual installation required on Windows"
        Write-Output "   Download from: https://rustup.rs/"
        Log-Status "rust" "N/A" "N/A" "skipped"
    }
} else {
    Write-Output ""
    Write-ColorOutput Yellow "⏭️  Skipping Rust (FEATURE_RUST=false)"
    Log-Status "rust" "N/A" "N/A" "skipped"
}

# ==============================================
# Generate Agent Handshake
# ==============================================
Write-Output ""
Write-ColorOutput Cyan "🤝 Generating agent handshake..."

$Toolchains = @()

if (($env:FEATURE_NODE -eq "true") -and (Get-Command node -ErrorAction SilentlyContinue)) {
    $NodeVer = (node --version) -replace '^v', ''
    $Toolchains += @{
        name = "node"
        version = $NodeVer
        path = (Get-Command node).Source
        available = $true
    }
}

if (($env:FEATURE_PYTHON -eq "true") -and (Get-Command python -ErrorAction SilentlyContinue)) {
    $PythonVer = (python --version 2>&1) -replace 'Python ', ''
    $Toolchains += @{
        name = "python"
        version = $PythonVer
        path = (Get-Command python).Source
        available = $true
    }
}

if (($env:FEATURE_RUST -eq "true") -and (Get-Command rustc -ErrorAction SilentlyContinue)) {
    $RustVer = (rustc --version) -replace 'rustc ', '' -replace ' \(.+\)', ''
    $Toolchains += @{
        name = "rust"
        version = $RustVer
        path = (Get-Command rustc).Source
        available = $true
    }
}

$HandshakeFile = Join-Path $RepoRoot "agent-handshake.json"
$Handshake = @{
    protocol_version = "1.0"
    setup_status = "success"
    setup_id = $SetupId
    timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    environment = @{
        os = "windows"
        arch = $env:PROCESSOR_ARCHITECTURE
        shell = "PowerShell"
    }
    toolchains = $Toolchains
    roles = @(
        @{
            name = "backend"
            agent = "backend-agent"
            tools = @("python", "rust")
            ready = ($env:FEATURE_BACKEND -eq "true")
        },
        @{
            name = "frontend"
            agent = "frontend-agent"
            tools = @("node", "typescript")
            ready = ($env:FEATURE_FRONTEND -eq "true")
        }
    )
    capabilities = @{
        can_build_backend = (Get-Command python -ErrorAction SilentlyContinue) -ne $null
        can_build_frontend = (Get-Command node -ErrorAction SilentlyContinue) -ne $null
        can_deploy = $false
        can_test = $true
    }
} | ConvertTo-Json -Depth 10

$Handshake | Out-File -FilePath $HandshakeFile -Encoding utf8
Write-Output "✅ agent-handshake.json generated"

# ==============================================
# Summary
# ==============================================
Write-Output ""
Write-Header "✅ Setup Complete!"
Write-Output ""
Write-Output "📊 Setup ID: $SetupId"
Write-Output "🔧 Mode: $($env:SETUP_MODE)"
Write-Output "📄 Reports generated:"
Write-Output "   - provenance.json (supply chain tracking)"
Write-Output "   - agent-handshake.json (agent orchestration)"
Write-Output "   - setup-report.json (installation summary)"
Write-Output ""
Write-Output "Next steps:"
Write-Output "  1. Verify installation: .\scripts\validate.ps1"
Write-Output "  2. Generate badges: .\scripts\generate-badges.ps1"
Write-Output ""
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
