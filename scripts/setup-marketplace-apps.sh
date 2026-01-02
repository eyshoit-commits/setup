#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🛠️  GitHub Marketplace Apps Setup${NC}"
echo ""

echo -e "${GREEN}✅ Configured (No Action Required):${NC}"
echo "  • Dependabot"
echo "  • GitHub CodeQL"
echo "  • Coveralls"
echo "  • CodeFactor (add repo manually)"
echo "  • CodeRabbit (install app)"
echo "  • CodiumAI (install app)"
echo ""

echo -e "${YELLOW}⚠️  Requires Secrets:${NC}"
echo "  1. Snyk → SNYK_TOKEN"
echo "  2. Codecov → CODECOV_TOKEN"
echo "  3. Codacy → CODACY_PROJECT_TOKEN"
echo "  4. WakaTime → WAKATIME_API_KEY"
echo ""

echo -e "${BLUE}📋 Next Steps:${NC}"
echo "  1. Go to: Settings → Secrets and variables → Actions"
echo "  2. Add required tokens (see docs/RECOMMENDED_MARKETPLACE_APPS.md)"
echo "  3. Enable branch protection with status checks"
echo ""

echo "📖 Full documentation: docs/RECOMMENDED_MARKETPLACE_APPS.md"
