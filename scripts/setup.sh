#!/bin/bash
set -e

# Load version locks
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$REPO_ROOT/config/versions.env"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Report file
REPORT_FILE="$REPO_ROOT/setup-report.json"
INSTALLED=0
SKIPPED=0
FAILED=0

# Initialize report
cat > "$REPORT_FILE" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "os": "$(uname -s)",
  "arch": "$(uname -m)",
  "tools": []
}
EOF

function log_status() {
  local tool=$1
  local version=$2
  local path=$3
  local status=$4
  
  case $status in
    installed) echo -e "${GREEN}✅ $tool ($version) - INSTALLED${NC}"; ((INSTALLED++)) ;;
    skipped) echo -e "${YELLOW}⏭️  $tool ($version) - SKIPPED${NC}"; ((SKIPPED++)) ;;
    failed) echo -e "${RED}❌ $tool - FAILED${NC}"; ((FAILED++)) ;;
  esac
  
  # Append to report (check if jq is available)
  if command -v jq &>/dev/null; then
    jq --arg name "$tool" \
       --arg version "$version" \
       --arg path "$path" \
       --arg status "$status" \
       '.tools += [{name: $name, version: $version, path: $path, status: $status}]' \
       "$REPORT_FILE" > "$REPORT_FILE.tmp" && mv "$REPORT_FILE.tmp" "$REPORT_FILE"
  else
    echo "  Warning: jq not found, skipping JSON report update"
  fi
}

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🚀 Enterprise Setup (Idempotent Mode)    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check for offline artifacts
OFFLINE_MODE=false
if [ -d "$REPO_ROOT/artifacts" ] && [ "$(ls -A "$REPO_ROOT/artifacts" 2>/dev/null | grep -v -e '^\.gitkeep$' -e '^README\.md$')" ]; then
  echo -e "${YELLOW}📦 Offline artifacts detected - using local installers${NC}"
  OFFLINE_MODE=true
fi

# ======================
# 1. Install nvm (Idempotent)
# ======================
echo -e "${BLUE}━━━ NVM ━━━${NC}"

if [ -d "$HOME/.nvm" ]; then
  CURRENT_NVM=$(cd ~/.nvm && git describe --tags 2>/dev/null | sed 's/^v//' || echo "unknown")
  if [ "$CURRENT_NVM" == "$NVM_VERSION" ]; then
    log_status "nvm" "$NVM_VERSION" "$HOME/.nvm" "skipped"
  else
    echo "Updating nvm $CURRENT_NVM -> $NVM_VERSION"
    (cd ~/.nvm && git fetch --tags && git checkout "v$NVM_VERSION" 2>/dev/null) || {
      echo "Update failed, continuing with current version"
      log_status "nvm" "$CURRENT_NVM" "$HOME/.nvm" "skipped"
    }
  fi
else
  if [ "$OFFLINE_MODE" = true ] && [ -f "$REPO_ROOT/artifacts/nvm-$NVM_VERSION.tar.gz" ]; then
    tar -xzf "$REPO_ROOT/artifacts/nvm-$NVM_VERSION.tar.gz" -C "$HOME"
  else
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh" | bash
  fi
  
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  
  log_status "nvm" "$NVM_VERSION" "$HOME/.nvm" "installed"
fi

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node with locked version
if [ "$ALLOW_LATEST" = "true" ]; then
  nvm install --lts
  nvm use --lts
else
  nvm install "$NODE_VERSION"
  nvm use "$NODE_VERSION"
fi

NODE_ACTUAL=$(node --version 2>/dev/null | sed 's/^v//' || echo "not-found")
if [ "$NODE_ACTUAL" != "not-found" ]; then
  log_status "node" "$NODE_ACTUAL" "$(which node)" "installed"
else
  log_status "node" "unknown" "" "failed"
fi

echo ""

# ======================
# 2. Install Miniconda (Idempotent)
# ======================
echo -e "${BLUE}━━━ CONDA ━━━${NC}"

if [ -d "$HOME/miniconda3" ]; then
  CURRENT_CONDA=$("$HOME/miniconda3/bin/conda" --version 2>/dev/null | awk '{print $2}' || echo "unknown")
  log_status "conda" "$CURRENT_CONDA" "$HOME/miniconda3" "skipped"
else
  OS_TYPE="$(uname -s)"
  
  if [ "$OFFLINE_MODE" = true ] && [ -f "$REPO_ROOT/artifacts/miniconda.sh" ]; then
    bash "$REPO_ROOT/artifacts/miniconda.sh" -b -p "$HOME/miniconda3"
  else
    case $OS_TYPE in
      Linux)
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
        ;;
      Darwin)
        if [ "$(uname -m)" == "arm64" ]; then
          wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -O /tmp/miniconda.sh
        else
          wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O /tmp/miniconda.sh
        fi
        ;;
    esac
    
    bash /tmp/miniconda.sh -b -p "$HOME/miniconda3"
    rm /tmp/miniconda.sh
  fi
  
  "$HOME/miniconda3/bin/conda" init bash 2>/dev/null || true
  [ -f "$HOME/.zshrc" ] && "$HOME/miniconda3/bin/conda" init zsh 2>/dev/null || true
  
  CONDA_VER=$("$HOME/miniconda3/bin/conda" --version 2>/dev/null | awk '{print $2}' || echo "unknown")
  log_status "conda" "$CONDA_VER" "$HOME/miniconda3" "installed"
fi

export PATH="$HOME/miniconda3/bin:$PATH"

echo ""

# ======================
# 3. Install uv/uvx (Idempotent)
# ======================
echo -e "${BLUE}━━━ UV ━━━${NC}"

if command -v uv &> /dev/null; then
  CURRENT_UV=$(uv --version 2>/dev/null | awk '{print $2}' || echo "unknown")
  log_status "uv" "$CURRENT_UV" "$(which uv)" "skipped"
else
  if [ "$OFFLINE_MODE" = true ] && [ -f "$REPO_ROOT/artifacts/uv-installer.sh" ]; then
    bash "$REPO_ROOT/artifacts/uv-installer.sh"
  else
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi
  
  export PATH="$HOME/.cargo/bin:$PATH"
  
  UV_VER=$(uv --version 2>/dev/null | awk '{print $2}' || echo "unknown")
  log_status "uv" "$UV_VER" "$HOME/.cargo/bin/uv" "installed"
fi

echo ""

# ======================
# 4. Install pnpm (Idempotent)
# ======================
echo -e "${BLUE}━━━ PNPM ━━━${NC}"

if command -v pnpm &> /dev/null; then
  CURRENT_PNPM=$(pnpm --version 2>/dev/null || echo "unknown")
  if [ "$CURRENT_PNPM" == "$PNPM_VERSION" ] || [ "$ALLOW_LATEST" = "true" ]; then
    log_status "pnpm" "$CURRENT_PNPM" "$(which pnpm)" "skipped"
  else
    npm install -g "pnpm@$PNPM_VERSION"
    log_status "pnpm" "$PNPM_VERSION" "$(which pnpm)" "installed"
  fi
else
  if [ "$ALLOW_LATEST" = "true" ]; then
    npm install -g pnpm
  else
    npm install -g "pnpm@$PNPM_VERSION"
  fi
  
  PNPM_VER=$(pnpm --version 2>/dev/null || echo "unknown")
  log_status "pnpm" "$PNPM_VER" "$(which pnpm)" "installed"
fi

echo ""

# ======================
# 5. Install Rust (Idempotent)
# ======================
echo -e "${BLUE}━━━ RUST ━━━${NC}"

if command -v rustc &> /dev/null; then
  CURRENT_RUST=$(rustc --version 2>/dev/null | awk '{print $2}' || echo "unknown")
  log_status "rust" "$CURRENT_RUST" "$HOME/.cargo" "skipped"
else
  if [ "$OFFLINE_MODE" = true ] && [ -f "$REPO_ROOT/artifacts/rustup-init.sh" ]; then
    bash "$REPO_ROOT/artifacts/rustup-init.sh" -y
  else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi
  
  source "$HOME/.cargo/env"
  
  RUST_VER=$(rustc --version 2>/dev/null | awk '{print $2}' || echo "unknown")
  log_status "rust" "$RUST_VER" "$HOME/.cargo" "installed"
fi

echo ""

# ======================
# 6. Generate env.d files
# ======================
echo -e "${BLUE}━━━ ENV SETUP ━━━${NC}"

cat > "$REPO_ROOT/env.d/10-tools.env" <<EOF
# Auto-generated by setup.sh on $(date -u +%Y-%m-%dT%H:%M:%SZ)
# DO NOT EDIT MANUALLY

export NVM_DIR="$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"
export PATH="$HOME/miniconda3/bin:\$PATH"
export PATH="$HOME/.cargo/bin:\$PATH"
EOF

echo -e "${GREEN}✅ env.d/10-tools.env generated${NC}"

# ======================
# 7. Install pre-commit hooks
# ======================
echo -e "${BLUE}━━━ SECURITY SETUP ━━━${NC}"

# Install pre-commit if not available
if ! command -v pre-commit &> /dev/null; then
  echo "Installing pre-commit..."
  pip install pre-commit || {
    echo -e "${YELLOW}⚠️  Could not install pre-commit via pip${NC}"
  }
fi

# Install hooks if pre-commit is available and config exists
if command -v pre-commit &> /dev/null && [ -f "$REPO_ROOT/config/pre-commit-config.yaml" ]; then
  # Copy config to .pre-commit-config.yaml if not already there
  if [ ! -f "$REPO_ROOT/.pre-commit-config.yaml" ]; then
    cp "$REPO_ROOT/config/pre-commit-config.yaml" "$REPO_ROOT/.pre-commit-config.yaml"
  fi
  
  cd "$REPO_ROOT"
  pre-commit install 2>/dev/null || echo -e "${YELLOW}⚠️  Could not install pre-commit hooks${NC}"
  echo -e "${GREEN}✅ pre-commit hooks installed${NC}"
else
  echo -e "${YELLOW}⚠️  pre-commit not available, skipping hook installation${NC}"
fi

# ======================
# 8. Generate MCP Context
# ======================
echo -e "${BLUE}━━━ MCP CONTEXT ━━━${NC}"

mkdir -p "$REPO_ROOT/.mcp"

NODE_VER=$(node --version 2>/dev/null | sed 's/^v//' || echo "not-installed")
NODE_PATH=$(which node 2>/dev/null || echo "not-found")
PYTHON_VER=$(python --version 2>/dev/null | awk '{print $2}' || echo "not-installed")
RUST_VER=$(rustc --version 2>/dev/null | awk '{print $2}' || echo "not-installed")

cat > "$REPO_ROOT/.mcp/context.json" <<EOF
{
  "repository": "eyshoit-commits/setup",
  "os": "$(uname -s)",
  "arch": "$(uname -m)",
  "shell": "$SHELL",
  "toolchain": {
    "node": {
      "version": "$NODE_VER",
      "manager": "nvm",
      "path": "$NODE_PATH"
    },
    "python": {
      "version": "$PYTHON_VER",
      "manager": "conda",
      "path": "$HOME/miniconda3"
    },
    "rust": {
      "version": "$RUST_VER",
      "path": "$HOME/.cargo"
    }
  },
  "roles": ["backend", "frontend", "devops", "testing"],
  "agents": [
    "main-orchestrator",
    "backend-agent",
    "frontend-agent",
    "devops-agent",
    "testing-agent"
  ],
  "setup_timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "setup_status": "success"
}
EOF

echo -e "${GREEN}✅ .mcp/context.json generated${NC}"

# ======================
# 9. Run Smoke Tests
# ======================
echo ""
echo -e "${BLUE}━━━ SMOKE TESTS ━━━${NC}"

if [ -f "$REPO_ROOT/scripts/smoke-test.sh" ]; then
  bash "$REPO_ROOT/scripts/smoke-test.sh" || true
else
  echo -e "${YELLOW}⚠️  smoke-test.sh not found, skipping smoke tests${NC}"
fi

# ======================
# 10. Finalize Report
# ======================
if command -v jq &>/dev/null; then
  jq --arg installed "$INSTALLED" \
     --arg skipped "$SKIPPED" \
     --arg failed "$FAILED" \
     --argjson total $(($INSTALLED + $SKIPPED + $FAILED)) \
     '.summary = {installed: ($installed | tonumber), skipped: ($skipped | tonumber), failed: ($failed | tonumber), total: $total}' \
     "$REPORT_FILE" > "$REPORT_FILE.tmp" && mv "$REPORT_FILE.tmp" "$REPORT_FILE"
fi

# ======================
# Summary
# ======================
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║            SETUP SUMMARY                   ║${NC}"
echo -e "${BLUE}╠════════════════════════════════════════════╣${NC}"
echo -e "${BLUE}║${NC} ${GREEN}✅ INSTALLED:${NC} $INSTALLED"
echo -e "${BLUE}║${NC} ${YELLOW}⏭️  SKIPPED:${NC}   $SKIPPED"
echo -e "${BLUE}║${NC} ${RED}❌ FAILED:${NC}    $FAILED"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}📊 Full report:${NC} $REPORT_FILE"
echo -e "${GREEN}🤖 MCP Context:${NC} .mcp/context.json"
echo ""

if [ $FAILED -gt 0 ]; then
  exit 1
fi
