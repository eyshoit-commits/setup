# Validation Script for Windows (PowerShell)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║     Environment Validation Check          ║" -ForegroundColor Blue
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

$ISSUES = 0

# Check if required directories exist
Write-Host "━━━ Directory Structure ━━━" -ForegroundColor Blue

$REQUIRED_DIRS = @("config", "scripts", "env.d", "artifacts")
foreach ($dir in $REQUIRED_DIRS) {
    $dirPath = Join-Path $RepoRoot $dir
    if (Test-Path $dirPath) {
        Write-Host "✅ $dir/" -ForegroundColor Green
    } else {
        Write-Host "❌ $dir/ (missing)" -ForegroundColor Red
        $ISSUES++
    }
}

Write-Host ""

# Check if required config files exist
Write-Host "━━━ Configuration Files ━━━" -ForegroundColor Blue

$REQUIRED_FILES = @(
    "config\versions.env",
    "config\.tool-versions",
    "config\requirements.txt",
    ".env.example",
    ".gitleaks.toml"
)

foreach ($file in $REQUIRED_FILES) {
    $filePath = Join-Path $RepoRoot $file
    if (Test-Path $filePath) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ $file (missing)" -ForegroundColor Red
        $ISSUES++
    }
}

Write-Host ""

# Check if tools are installed
Write-Host "━━━ Installed Tools ━━━" -ForegroundColor Blue

$TOOLS = @("git", "curl", "powershell")
foreach ($tool in $TOOLS) {
    if (Get-Command $tool -ErrorAction SilentlyContinue) {
        $toolPath = (Get-Command $tool).Source
        Write-Host "✅ $tool ($toolPath)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  $tool (not found)" -ForegroundColor Yellow
    }
}

Write-Host ""

# Check environment variables
Write-Host "━━━ Environment ━━━" -ForegroundColor Blue
Write-Host "OS: Windows"
Write-Host "Architecture: $([System.Environment]::Is64BitOperatingSystem ? 'x64' : 'x86')"
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Host "Home: $env:USERPROFILE"

Write-Host ""

# Summary
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║         Validation Summary                 ║" -ForegroundColor Blue
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Blue

if ($ISSUES -eq 0) {
    Write-Host "✅ All checks passed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now run: .\scripts\setup.ps1"
    exit 0
} else {
    Write-Host "❌ $ISSUES issue(s) found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please fix the issues above before running setup."
    exit 1
}
