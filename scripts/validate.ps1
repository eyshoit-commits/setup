# ==============================================
# Drift Detection & Validation Script (PowerShell)
# ==============================================
# Validates that installed tool versions match expected versions
# In REPRO mode, fails on any drift
# In dev mode, warns on drift but continues

$ErrorActionPreference = "Stop"

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

Write-Header "🔍 Drift Detection & Validation"
Write-Output ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
Set-Location $RepoRoot

# Load configuration
$ConfigFile = Join-Path $RepoRoot "config\versions.env"
if (Test-Path $ConfigFile) {
    Get-Content $ConfigFile | ForEach-Object {
        if ($_ -match '^\s*([A-Z_]+)=(.+)$') {
            $name = $matches[1]
            $value = $matches[2]
            Set-Item -Path "env:$name" -Value $value
        }
    }
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
}

if (-not $env:SETUP_MODE) {
    $env:SETUP_MODE = "dev"
}

Write-Output "🔧 Mode: $($env:SETUP_MODE)"
Write-Output "📋 Strict Versions: $($env:STRICT_VERSIONS)"
Write-Output ""

$Drifts = 0
$Checks = 0

function Check-Drift {
    param(
        [string]$Tool,
        [string]$Expected,
        [string]$Actual
    )
    
    $script:Checks++
    
    if ($Expected -ne $Actual) {
        if ($env:SETUP_MODE -eq "repro") {
            Write-ColorOutput Red "❌ DRIFT: $Tool expected $Expected, got $Actual (REPRO mode - FAILING)"
            $script:Drifts++
            return $false
        } else {
            Write-ColorOutput Yellow "⚠️  DRIFT: $Tool expected $Expected, got $Actual (dev mode - warning)"
            $script:Drifts++
        }
    } else {
        Write-ColorOutput Green "✅ $Tool version match: $Actual"
    }
    return $true
}

# Check Node
if ($env:FEATURE_NODE -eq "true") {
    Write-ColorOutput Cyan "Checking Node.js..."
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $ActualNode = (node --version) -replace '^v', ''
        Check-Drift "node" $env:NODE_VERSION $ActualNode | Out-Null
    } else {
        Write-ColorOutput Red "❌ node not installed (expected $($env:NODE_VERSION))"
        $Drifts++
        $Checks++
    }
}

# Check Python
if ($env:FEATURE_PYTHON -eq "true") {
    Write-ColorOutput Cyan "Checking Python..."
    if (Get-Command python -ErrorAction SilentlyContinue) {
        $ActualPython = (python --version 2>&1) -replace 'Python ', ''
        Check-Drift "python" $env:PYTHON_VERSION $ActualPython | Out-Null
    } else {
        Write-ColorOutput Red "❌ python not installed (expected $($env:PYTHON_VERSION))"
        $Drifts++
        $Checks++
    }
}

# Check Rust
if ($env:FEATURE_RUST -eq "true") {
    Write-ColorOutput Cyan "Checking Rust..."
    if (Get-Command rustc -ErrorAction SilentlyContinue) {
        $ActualRust = (rustc --version) -replace 'rustc ', '' -replace ' \(.+\)', ''
        Check-Drift "rust" $env:RUST_VERSION $ActualRust | Out-Null
    } else {
        Write-ColorOutput Red "❌ rustc not installed (expected $($env:RUST_VERSION))"
        $Drifts++
        $Checks++
    }
}

# Check provenance
Write-Output ""
Write-ColorOutput Cyan "Checking provenance..."
$ProvenanceFile = Join-Path $RepoRoot "provenance.json"
if (Test-Path $ProvenanceFile) {
    Write-ColorOutput Green "✅ provenance.json exists"
    
    $Prov = Get-Content $ProvenanceFile | ConvertFrom-Json
    Write-Output "   Setup ID: $($Prov.setup_id)"
    Write-Output "   Timestamp: $($Prov.timestamp)"
} else {
    Write-ColorOutput Yellow "⚠️  provenance.json not found"
}

# Check agent handshake
Write-Output ""
Write-ColorOutput Cyan "Checking agent handshake..."
$HandshakeFile = Join-Path $RepoRoot "agent-handshake.json"
if (Test-Path $HandshakeFile) {
    Write-ColorOutput Green "✅ agent-handshake.json exists"
    
    $Handshake = Get-Content $HandshakeFile | ConvertFrom-Json
    Write-Output "   Status: $($Handshake.setup_status)"
    Write-Output "   Protocol: $($Handshake.protocol_version)"
} else {
    Write-ColorOutput Yellow "⚠️  agent-handshake.json not found"
}

# Summary
Write-Output ""
Write-Header ""
if ($Drifts -eq 0) {
    Write-ColorOutput Green "✅ No drift detected - all $Checks version checks passed"
    exit 0
} else {
    Write-ColorOutput Yellow "⚠️  $Drifts drift(s) detected out of $Checks checks"
    
    if ($env:SETUP_MODE -eq "repro") {
        Write-ColorOutput Red "❌ REPRO mode - exiting with error"
        exit 1
    } else {
        Write-ColorOutput Yellow "ℹ️  Dev mode - continuing with warning"
        exit 0
    }
}
