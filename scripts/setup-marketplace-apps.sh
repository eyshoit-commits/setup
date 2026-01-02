#!/bin/bash
# Initial Setup für alle empfohlenen Marketplace Apps & Enterprise Scripts
# Initial Setup for all recommended Marketplace Apps & Enterprise Scripts

set -e

echo "=================================="
echo "🚀 Enterprise Setup - Marketplace Apps"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Prüfe Secrets / Checking Secrets..."
REQUIRED_SECRETS=(
  SNYK_TOKEN
  CODECOV_TOKEN
  CODACY_PROJECT_TOKEN
  WAKATIME_API_KEY
  GITHUB_TOKEN
  OPENAI_API_KEY
  ANTHROPIC_API_KEY
)

MISSING=0
for s in "${REQUIRED_SECRETS[@]}"; do
  if ! gh secret list 2>/dev/null | grep -q "$s"; then
    echo -e "${YELLOW}⚠️  Secret $s fehlt / missing!${NC}"
    MISSING=1
  else
    echo -e "${GREEN}✅ Secret $s vorhanden / available${NC}"
  fi
done

if [ $MISSING -eq 1 ]; then
  echo ""
  echo -e "${RED}⚠️  Bitte fehlende Secrets setzen / Set missing secrets before proceeding.${NC}"
  echo ""
  echo "Verwende / Use: gh secret set SECRET_NAME"
  echo "Oder / Or: GitHub UI -> Settings -> Secrets and variables -> Actions"
  echo ""
  echo "Template verfügbar in / Template available at: .github/secrets-template.env"
  exit 1
fi

echo ""
echo -e "${GREEN}✅ Alle Secrets vorhanden / All secrets available${NC}"
echo ""

echo "⚙️  Installiere GitHub Apps / Installing GitHub Apps..."
echo ""
echo "Bitte installiere folgende Apps über GitHub Marketplace:"
echo "Please install the following apps via GitHub Marketplace:"
echo ""
echo "1. 🐰 CodeRabbit AI Code Review"
echo "   https://github.com/apps/coderabbitai"
echo "   - Automatische PR-Reviews / Automatic PR reviews"
echo "   - Code-Qualitätsanalyse / Code quality analysis"
echo ""
echo "2. 🤖 CodiumAI PR Agent"
echo "   https://github.com/apps/codiumai-pr-agent"
echo "   - AI-gestützte Code-Reviews / AI-powered code reviews"
echo "   - Test-Generierung / Test generation"
echo ""
echo "3. 📊 CodeFactor"
echo "   https://www.codefactor.io/"
echo "   - Code-Qualitätsbewertung / Code quality scoring"
echo "   - Automatische Analysen / Automatic analysis"
echo ""
echo "4. 🔍 Codacy"
echo "   https://www.codacy.com/"
echo "   - Code-Qualitätsüberwachung / Code quality monitoring"
echo "   - Automatische Reviews / Automatic reviews"
echo ""
echo "5. 📈 Codecov"
echo "   https://codecov.io/"
echo "   - Test-Coverage Tracking / Test coverage tracking"
echo "   - Coverage-Reports / Coverage reports"
echo ""
echo "6. 🔒 Snyk"
echo "   https://snyk.io/"
echo "   - Sicherheitsscan / Security scanning"
echo "   - Dependency-Überwachung / Dependency monitoring"
echo ""
echo "7. 🔄 Dependabot"
echo "   Bereits integriert / Already integrated"
echo "   - Automatische Dependency-Updates / Automatic dependency updates"
echo ""

echo "🎯 Workflow-Konfiguration / Workflow Configuration..."
echo ""
echo "Workflows sind bereits konfiguriert in:"
echo "Workflows are already configured in:"
echo "  - .github/workflows/setup-validation.yml"
echo "  - .github/workflows/security-scan.yml"
echo "  - .github/workflows/code-quality.yml"
echo "  - .github/workflows/ai-review.yml"
echo "  - .github/workflows/mcp-health-check.yml"
echo "  - .github/workflows/drift-check.yml"
echo "  - .github/workflows/commit-validation.yml"
echo "  - .github/workflows/sandbox-test.yml"
echo ""

echo "🚀 Initialisierung abgeschlossen / Initialization complete"
echo ""
echo "📌 Nächster Schritt / Next Step:"
echo "   Branch Protection aktivieren / Enable branch protection"
echo "   Verwende / Use: .github/branch-protection.json als Referenz / as reference"
echo ""
echo "📚 Dokumentation / Documentation:"
echo "   - docs/SETUP_GUIDE.md"
echo "   - docs/RECOMMENDED_MARKETPLACE_APPS.md"
echo "   - docs/ARCHITECTURE.md"
echo ""
echo "✅ Setup erfolgreich abgeschlossen / Setup completed successfully!"
