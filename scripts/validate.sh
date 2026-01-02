#!/bin/bash
# ==============================================
# Drift Detection & Validation Script
# ==============================================
# Validates that installed tool versions match expected versions
# In REPRO mode, fails on any drift
# In dev mode, warns on drift but continues

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔍 Drift Detection & Validation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Load configuration
if [ -f "config/versions.env" ]; then
  source config/versions.env
else
  echo -e "${RED}❌ config/versions.env not found${NC}"
  exit 1
fi

if [ -f "env.d/20-features.env" ]; then
  source env.d/20-features.env
fi

echo "🔧 Mode: $SETUP_MODE"
echo "📋 Strict Versions: $STRICT_VERSIONS"
echo ""

DRIFTS=0
CHECKS=0

# Function to check drift
check_drift() {
  local tool=$1
  local expected=$2
  local actual=$3

  ((CHECKS++))

  if [ "$expected" != "$actual" ]; then
    if [ "$SETUP_MODE" = "repro" ]; then
      echo -e "${RED}❌ DRIFT: $tool expected $expected, got $actual (REPRO mode - FAILING)${NC}"
      ((DRIFTS++))
      return 1
    else
      echo -e "${YELLOW}⚠️  DRIFT: $tool expected $expected, got $actual (dev mode - warning)${NC}"
      ((DRIFTS++))
    fi
  else
    echo -e "${GREEN}✅ $tool version match: $actual${NC}"
  fi
}

# Check Node
if [ "$FEATURE_NODE" = "true" ]; then
  echo -e "${BLUE}Checking Node.js...${NC}"
  if command -v node &> /dev/null; then
    ACTUAL_NODE=$(node --version 2>/dev/null | sed 's/^v//' || echo "not_installed")
    check_drift "node" "$NODE_VERSION" "$ACTUAL_NODE"
  else
    echo -e "${RED}❌ node not installed (expected $NODE_VERSION)${NC}"
    ((DRIFTS++))
    ((CHECKS++))
  fi
fi

# Check Python
if [ "$FEATURE_PYTHON" = "true" ]; then
  echo -e "${BLUE}Checking Python...${NC}"
  if command -v python &> /dev/null; then
    ACTUAL_PYTHON=$(python --version 2>/dev/null | awk '{print $2}' || echo "not_installed")
    # Python version might have extra patch version, so check prefix
    if [[ "$ACTUAL_PYTHON" == "$PYTHON_VERSION"* ]]; then
      # Version matches prefix (e.g., 3.12.1 matches 3.12.1*)
      echo -e "${GREEN}✅ python version match: $ACTUAL_PYTHON${NC}"
      ((CHECKS++))
    else
      check_drift "python" "$PYTHON_VERSION" "$ACTUAL_PYTHON"
    fi
  else
    echo -e "${RED}❌ python not installed (expected $PYTHON_VERSION)${NC}"
    ((DRIFTS++))
    ((CHECKS++))
  fi
fi

# Check Rust
if [ "$FEATURE_RUST" = "true" ]; then
  echo -e "${BLUE}Checking Rust...${NC}"
  if command -v rustc &> /dev/null; then
    ACTUAL_RUST=$(rustc --version 2>/dev/null | awk '{print $2}' || echo "not_installed")
    check_drift "rust" "$RUST_VERSION" "$ACTUAL_RUST"
  else
    echo -e "${RED}❌ rustc not installed (expected $RUST_VERSION)${NC}"
    ((DRIFTS++))
    ((CHECKS++))
  fi
fi

# Check provenance file
echo ""
echo -e "${BLUE}Checking provenance...${NC}"
if [ -f "provenance.json" ]; then
  echo -e "${GREEN}✅ provenance.json exists${NC}"

  if command -v jq &> /dev/null; then
    SETUP_ID=$(jq -r '.setup_id' provenance.json)
    TIMESTAMP=$(jq -r '.timestamp' provenance.json)
    echo "   Setup ID: $SETUP_ID"
    echo "   Timestamp: $TIMESTAMP"
  fi
else
  echo -e "${YELLOW}⚠️  provenance.json not found${NC}"
fi

# Check agent handshake
echo ""
echo -e "${BLUE}Checking agent handshake...${NC}"
if [ -f "agent-handshake.json" ]; then
  echo -e "${GREEN}✅ agent-handshake.json exists${NC}"

  if command -v jq &> /dev/null; then
    STATUS=$(jq -r '.setup_status' agent-handshake.json)
    PROTOCOL=$(jq -r '.protocol_version' agent-handshake.json)
    echo "   Status: $STATUS"
    echo "   Protocol: $PROTOCOL"
  fi
else
  echo -e "${YELLOW}⚠️  agent-handshake.json not found${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ $DRIFTS -eq 0 ]; then
  echo -e "${GREEN}✅ No drift detected - all $CHECKS version checks passed${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  exit 0
else
  echo -e "${YELLOW}⚠️  $DRIFTS drift(s) detected out of $CHECKS checks${NC}"

  if [ "$SETUP_MODE" = "repro" ]; then
    echo -e "${RED}❌ REPRO mode - exiting with error${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 1
  else
    echo -e "${YELLOW}ℹ️  Dev mode - continuing with warning${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
  fi

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
