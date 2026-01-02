# Initial Setup für alle empfohlenen Marketplace Apps & Enterprise Scripts
# Initial Setup for all recommended Marketplace Apps & Enterprise Scripts

$ErrorActionPreference = "Stop"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "🚀 Enterprise Setup - Marketplace Apps" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔍 Prüfe Secrets / Checking Secrets..." -ForegroundColor Yellow

$REQUIRED_SECRETS = @(
    "SNYK_TOKEN",
    "CODECOV_TOKEN",
    "CODACY_PROJECT_TOKEN",
    "WAKATIME_API_KEY",
    "GITHUB_TOKEN",
    "OPENAI_API_KEY",
    "ANTHROPIC_API_KEY"
)

$MISSING = 0
foreach ($secret in $REQUIRED_SECRETS) {
    try {
        $secretExists = gh secret list 2>$null | Select-String -Pattern $secret -Quiet
        if ($secretExists) {
            Write-Host "✅ Secret $secret vorhanden / available" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Secret $secret fehlt / missing!" -ForegroundColor Yellow
            $MISSING = 1
        }
    } catch {
        Write-Host "⚠️  Secret $secret fehlt / missing!" -ForegroundColor Yellow
        $MISSING = 1
    }
}

if ($MISSING -eq 1) {
    Write-Host ""
    Write-Host "⚠️  Bitte fehlende Secrets setzen / Set missing secrets before proceeding." -ForegroundColor Red
    Write-Host ""
    Write-Host "Verwende / Use: gh secret set SECRET_NAME"
    Write-Host "Oder / Or: GitHub UI -> Settings -> Secrets and variables -> Actions"
    Write-Host ""
    Write-Host "Template verfügbar in / Template available at: .github/secrets-template.env"
    exit 1
}

Write-Host ""
Write-Host "✅ Alle Secrets vorhanden / All secrets available" -ForegroundColor Green
Write-Host ""

Write-Host "⚙️  Installiere GitHub Apps / Installing GitHub Apps..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Bitte installiere folgende Apps über GitHub Marketplace:"
Write-Host "Please install the following apps via GitHub Marketplace:"
Write-Host ""
Write-Host "1. 🐰 CodeRabbit AI Code Review"
Write-Host "   https://github.com/apps/coderabbitai"
Write-Host "   - Automatische PR-Reviews / Automatic PR reviews"
Write-Host "   - Code-Qualitätsanalyse / Code quality analysis"
Write-Host ""
Write-Host "2. 🤖 CodiumAI PR Agent"
Write-Host "   https://github.com/apps/codiumai-pr-agent"
Write-Host "   - AI-gestützte Code-Reviews / AI-powered code reviews"
Write-Host "   - Test-Generierung / Test generation"
Write-Host ""
Write-Host "3. 📊 CodeFactor"
Write-Host "   https://www.codefactor.io/"
Write-Host "   - Code-Qualitätsbewertung / Code quality scoring"
Write-Host "   - Automatische Analysen / Automatic analysis"
Write-Host ""
Write-Host "4. 🔍 Codacy"
Write-Host "   https://www.codacy.com/"
Write-Host "   - Code-Qualitätsüberwachung / Code quality monitoring"
Write-Host "   - Automatische Reviews / Automatic reviews"
Write-Host ""
Write-Host "5. 📈 Codecov"
Write-Host "   https://codecov.io/"
Write-Host "   - Test-Coverage Tracking / Test coverage tracking"
Write-Host "   - Coverage-Reports / Coverage reports"
Write-Host ""
Write-Host "6. 🔒 Snyk"
Write-Host "   https://snyk.io/"
Write-Host "   - Sicherheitsscan / Security scanning"
Write-Host "   - Dependency-Überwachung / Dependency monitoring"
Write-Host ""
Write-Host "7. 🔄 Dependabot"
Write-Host "   Bereits integriert / Already integrated"
Write-Host "   - Automatische Dependency-Updates / Automatic dependency updates"
Write-Host ""

Write-Host "🎯 Workflow-Konfiguration / Workflow Configuration..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Workflows sind bereits konfiguriert in:"
Write-Host "Workflows are already configured in:"
Write-Host "  - .github/workflows/setup-validation.yml"
Write-Host "  - .github/workflows/security-scan.yml"
Write-Host "  - .github/workflows/code-quality.yml"
Write-Host "  - .github/workflows/ai-review.yml"
Write-Host "  - .github/workflows/mcp-health-check.yml"
Write-Host "  - .github/workflows/drift-check.yml"
Write-Host "  - .github/workflows/commit-validation.yml"
Write-Host "  - .github/workflows/sandbox-test.yml"
Write-Host ""

Write-Host "🚀 Initialisierung abgeschlossen / Initialization complete" -ForegroundColor Green
Write-Host ""
Write-Host "📌 Nächster Schritt / Next Step:"
Write-Host "   Branch Protection aktivieren / Enable branch protection"
Write-Host "   Verwende / Use: .github/branch-protection.json als Referenz / as reference"
Write-Host ""
Write-Host "📚 Dokumentation / Documentation:"
Write-Host "   - docs/SETUP_GUIDE.md"
Write-Host "   - docs/RECOMMENDED_MARKETPLACE_APPS.md"
Write-Host "   - docs/ARCHITECTURE.md"
Write-Host ""
Write-Host "✅ Setup erfolgreich abgeschlossen / Setup completed successfully!" -ForegroundColor Green
