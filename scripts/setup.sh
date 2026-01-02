#!/bin/bash
set -euo pipefail

echo "🚀 Starting Repository Setup..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check prerequisites
command -v node >/dev/null 2>&1 || { echo -e "${RED}❌ Node.js required${NC}"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo -e "${RED}❌ npm required${NC}"; exit 1; }
command -v gh >/dev/null 2>&1 || { echo -e "${YELLOW}⚠️  GitHub CLI recommended${NC}"; }

# Install dependencies
echo -e "${GREEN}📦 Installing dependencies...${NC}"
npm install

# Setup .opencode
echo -e "${GREEN}⚙️  Setting up OpenCode...${NC}"
if [ ! -d ".opencode" ]; then
  echo -e "${YELLOW}⚠️  .opencode directory not found, creating...${NC}"
  mkdir -p .opencode/agents
fi

# Verify secrets
echo -e "${GREEN}🔐 Checking secrets...${NC}"
REQUIRED_SECRETS=(SNYK_TOKEN CODECOV_TOKEN CODACY_PROJECT_TOKEN WAKATIME_API_KEY)
MISSING=0

for secret in "${REQUIRED_SECRETS[@]}"; do
  if gh secret list 2>/dev/null | grep -q "$secret"; then
    echo -e "${GREEN}✓${NC} $secret"
  else
    echo -e "${RED}✗${NC} $secret ${YELLOW}(missing)${NC}"
    MISSING=1
  fi
done

if [ $MISSING -eq 1 ]; then
  echo -e "${YELLOW}⚠️  Add missing secrets: gh secret set SECRET_NAME${NC}"
fi

# Setup Git hooks
echo -e "${GREEN}🪝 Setting up Git hooks...${NC}"
mkdir -p .git/hooks
cat > .git/hooks/pre-commit <<'HOOK_EOF'
#!/bin/bash
npm run lint
npm test
HOOK_EOF
chmod +x .git/hooks/pre-commit

echo -e "${GREEN}✅ Setup complete!${NC}"
echo -e "${GREEN}📖 Next steps:${NC}"
echo -e "  1. Add missing secrets (if any)"
echo -e "  2. Run: npm test"
echo -e "  3. Run: npm run lint"
echo -e "  4. Commit your changes"
