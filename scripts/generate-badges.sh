#!/bin/bash
# ==============================================
# README Badge Generator
# ==============================================
# Generates shields.io badges from setup-report.json

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
echo -e "${BLUE}🎨 README Badge Generator${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ ! -f "setup-report.json" ]; then
  echo -e "${RED}❌ setup-report.json not found - run ./scripts/setup.sh first${NC}"
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo -e "${YELLOW}⚠️  jq not found - generating basic badges${NC}"

  cat > README-badges.md <<EOF
<!-- Auto-generated badges from setup-report.json -->
![Status](https://img.shields.io/badge/setup-unknown-lightgrey)
![OS](https://img.shields.io/badge/os-unknown-blue)
![Arch](https://img.shields.io/badge/arch-unknown-blue)
EOF

  echo -e "${GREEN}✅ Basic badges generated in README-badges.md${NC}"
  exit 0
fi

# Extract information from setup-report.json
OS=$(jq -r '.os' setup-report.json)
ARCH=$(jq -r '.arch' setup-report.json)
FAILED=$(jq -r '.summary.failed' setup-report.json)
INSTALLED=$(jq -r '.summary.installed' setup-report.json)
MODE=$(jq -r '.mode' setup-report.json)

# Get tool versions
NODE_VER=$(jq -r '.tools[] | select(.name=="node") | .version' setup-report.json 2>/dev/null || echo "N/A")
PYTHON_VER=$(jq -r '.tools[] | select(.name=="python") | .version' setup-report.json 2>/dev/null || echo "N/A")
RUST_VER=$(jq -r '.tools[] | select(.name=="rust") | .version' setup-report.json 2>/dev/null || echo "N/A")

# Determine status badge
if [ "$FAILED" = "0" ]; then
  STATUS_BADGE="![Status](https://img.shields.io/badge/setup-passing-brightgreen)"
else
  STATUS_BADGE="![Status](https://img.shields.io/badge/setup-failing-red)"
fi

# Mode badge
if [ "$MODE" = "repro" ]; then
  MODE_BADGE="![Mode](https://img.shields.io/badge/mode-repro-blue)"
else
  MODE_BADGE="![Mode](https://img.shields.io/badge/mode-dev-yellow)"
fi

# Generate badges file
cat > README-badges.md <<EOF
<!-- Auto-generated badges from setup-report.json -->
<!-- Generated on $(date -u +"%Y-%m-%d %H:%M:%S UTC") -->

$STATUS_BADGE
$MODE_BADGE
![OS](https://img.shields.io/badge/os-${OS}-blue)
![Arch](https://img.shields.io/badge/arch-${ARCH}-blue)
![Tools Installed](https://img.shields.io/badge/tools-${INSTALLED}-green)
EOF

# Add tool-specific badges
if [ "$NODE_VER" != "N/A" ] && [ "$NODE_VER" != "null" ]; then
  echo "![Node](https://img.shields.io/badge/node-${NODE_VER}-green)" >> README-badges.md
fi

if [ "$PYTHON_VER" != "N/A" ] && [ "$PYTHON_VER" != "null" ]; then
  echo "![Python](https://img.shields.io/badge/python-${PYTHON_VER}-green)" >> README-badges.md
fi

if [ "$RUST_VER" != "N/A" ] && [ "$RUST_VER" != "null" ]; then
  echo "![Rust](https://img.shields.io/badge/rust-${RUST_VER}-green)" >> README-badges.md
fi

echo ""
echo -e "${GREEN}✅ Badges generated in README-badges.md${NC}"
echo ""
echo -e "${BLUE}Preview:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat README-badges.md
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Add these badges to your README.md"
echo ""
