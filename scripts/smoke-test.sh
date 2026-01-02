#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

FAILED=0

echo "Running smoke tests..."
echo ""

# Node
if node --version &>/dev/null; then
  echo -e "${GREEN}✅ Node smoke test passed${NC} ($(node --version))"
else
  echo -e "${RED}❌ Node smoke test FAILED${NC}"
  ((FAILED++))
fi

# Python (via uvx)
if command -v uvx &>/dev/null && uvx ruff --version &>/dev/null; then
  echo -e "${GREEN}✅ Python/uvx smoke test passed${NC} ($(uvx ruff --version))"
else
  echo -e "${RED}❌ Python/uvx smoke test FAILED${NC}"
  ((FAILED++))
fi

# Rust
if cargo --version &>/dev/null; then
  echo -e "${GREEN}✅ Rust smoke test passed${NC} ($(cargo --version))"
else
  echo -e "${RED}❌ Rust smoke test FAILED${NC}"
  ((FAILED++))
fi

# pnpm
if pnpm store path &>/dev/null; then
  echo -e "${GREEN}✅ pnpm smoke test passed${NC} ($(pnpm --version))"
else
  echo -e "${RED}❌ pnpm smoke test FAILED${NC}"
  ((FAILED++))
fi

# Update report if it exists
if [ -f "$REPO_ROOT/setup-report.json" ] && command -v jq &>/dev/null; then
  NODE_STATUS="passed"
  PYTHON_STATUS="passed"
  RUST_STATUS="passed"
  PNPM_STATUS="passed"
  
  node --version &>/dev/null || NODE_STATUS="failed"
  (command -v uvx &>/dev/null && uvx ruff --version &>/dev/null) || PYTHON_STATUS="failed"
  cargo --version &>/dev/null || RUST_STATUS="failed"
  pnpm store path &>/dev/null || PNPM_STATUS="failed"
  
  jq --arg node "$NODE_STATUS" \
     --arg python "$PYTHON_STATUS" \
     --arg rust "$RUST_STATUS" \
     --arg pnpm "$PNPM_STATUS" \
     '.smoke_tests = {node: $node, python: $python, rust: $rust, pnpm: $pnpm}' \
     "$REPO_ROOT/setup-report.json" > "$REPO_ROOT/setup-report.json.tmp" && \
     mv "$REPO_ROOT/setup-report.json.tmp" "$REPO_ROOT/setup-report.json"
fi

echo ""
if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ All smoke tests passed!${NC}"
else
  echo -e "${RED}❌ $FAILED smoke test(s) failed${NC}"
fi

exit $FAILED
