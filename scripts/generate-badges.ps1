# ==============================================
# README Badge Generator (PowerShell)
# ==============================================
# Generates shields.io badges from setup-report.json

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

Write-Header "🎨 README Badge Generator"
Write-Output ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
Set-Location $RepoRoot

$ReportFile = Join-Path $RepoRoot "setup-report.json"
if (-not (Test-Path $ReportFile)) {
    Write-ColorOutput Red "❌ setup-report.json not found - run .\scripts\setup.ps1 first"
    exit 1
}

# Parse setup report
$Report = Get-Content $ReportFile | ConvertFrom-Json

$Os = $Report.os
$Arch = $Report.arch
$Failed = $Report.summary.failed
$Installed = $Report.summary.installed
$Mode = $Report.mode

# Get tool versions
$NodeVer = ($Report.tools | Where-Object { $_.name -eq "node" }).version
$PythonVer = ($Report.tools | Where-Object { $_.name -eq "python" }).version
$RustVer = ($Report.tools | Where-Object { $_.name -eq "rust" }).version

if (-not $NodeVer) { $NodeVer = "N/A" }
if (-not $PythonVer) { $PythonVer = "N/A" }
if (-not $RustVer) { $RustVer = "N/A" }

# Determine status badge
if ($Failed -eq 0) {
    $StatusBadge = "![Status](https://img.shields.io/badge/setup-passing-brightgreen)"
} else {
    $StatusBadge = "![Status](https://img.shields.io/badge/setup-failing-red)"
}

# Mode badge
if ($Mode -eq "repro") {
    $ModeBadge = "![Mode](https://img.shields.io/badge/mode-repro-blue)"
} else {
    $ModeBadge = "![Mode](https://img.shields.io/badge/mode-dev-yellow)"
}

# Generate badges file
$BadgesFile = Join-Path $RepoRoot "README-badges.md"
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"

$BadgeContent = @"
<!-- Auto-generated badges from setup-report.json -->
<!-- Generated on $Timestamp -->

$StatusBadge
$ModeBadge
![OS](https://img.shields.io/badge/os-$Os-blue)
![Arch](https://img.shields.io/badge/arch-$Arch-blue)
![Tools Installed](https://img.shields.io/badge/tools-$Installed-green)
"@

# Add tool-specific badges
if ($NodeVer -ne "N/A") {
    $BadgeContent += "`n![Node](https://img.shields.io/badge/node-$NodeVer-green)"
}

if ($PythonVer -ne "N/A") {
    $BadgeContent += "`n![Python](https://img.shields.io/badge/python-$PythonVer-green)"
}

if ($RustVer -ne "N/A") {
    $BadgeContent += "`n![Rust](https://img.shields.io/badge/rust-$RustVer-green)"
}

$BadgeContent | Out-File -FilePath $BadgesFile -Encoding utf8

Write-Output ""
Write-ColorOutput Green "✅ Badges generated in README-badges.md"
Write-Output ""
Write-ColorOutput Cyan "Preview:"
Write-Output "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Get-Content $BadgesFile | Write-Output
Write-Output "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Output ""
Write-Output "Add these badges to your README.md"
Write-Output ""
