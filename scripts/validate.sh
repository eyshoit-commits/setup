#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Environment Validation Check          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

ISSUES=0

# Check if required directories exist
echo -e "${BLUE}━━━ Directory Structure ━━━${NC}"

REQUIRED_DIRS=("config" "scripts" "env.d" "artifacts")
for dir in "${REQUIRED_DIRS[@]}"; do
  if [ -d "$REPO_ROOT/$dir" ]; then
    echo -e "${GREEN}✅${NC} $dir/"
  else
    echo -e "${RED}❌${NC} $dir/ (missing)"
    ((ISSUES++))
  fi
done

echo ""

# Check if required config files exist
echo -e "${BLUE}━━━ Configuration Files ━━━${NC}"

REQUIRED_FILES=(
  "config/versions.env"
  "config/.tool-versions"
  "config/requirements.txt"
  ".env.example"
  ".gitleaks.toml"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ -f "$REPO_ROOT/$file" ]; then
    echo -e "${GREEN}✅${NC} $file"
  else
    echo -e "${RED}❌${NC} $file (missing)"
    ((ISSUES++))
  fi
done

echo ""

# Check if tools are installed
echo -e "${BLUE}━━━ Installed Tools ━━━${NC}"

TOOLS=("git" "curl" "wget" "bash")
for tool in "${TOOLS[@]}"; do
  if command -v "$tool" &>/dev/null; then
    echo -e "${GREEN}✅${NC} $tool ($(command -v "$tool"))"
  else
    echo -e "${YELLOW}⚠️${NC}  $tool (not found)"
  fi
done

echo ""

# Check environment variables
echo -e "${BLUE}━━━ Environment ━━━${NC}"
echo "OS: $(uname -s)"
echo "Architecture: $(uname -m)"
echo "Shell: $SHELL"
echo "Home: $HOME"

echo ""

# Summary
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Validation Summary                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"

if [ $ISSUES -eq 0 ]; then
  echo -e "${GREEN}✅ All checks passed!${NC}"
  echo ""
  echo "You can now run: bash scripts/setup.sh"
  exit 0
else
  echo -e "${RED}❌ $ISSUES issue(s) found${NC}"
  echo ""
  echo "Please fix the issues above before running setup."
  exit 1
fi
