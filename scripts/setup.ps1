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
