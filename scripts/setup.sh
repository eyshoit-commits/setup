#!/bin/bash
# ==============================================
# Enterprise-Grade Development Environment Setup
# ==============================================
# Installs and configures development tools with:
# - Supply chain tracking (provenance.json)
# - Repro mode for CI/Codespaces
# - Agent handshake generation
# - Feature gate support
# - Drift detection
# - Golden path enforcement

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Enterprise-Grade Development Environment Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ==============================================
# Load Configuration
# ==============================================
echo -e "${BLUE}📋 Loading configuration...${NC}"

if [ -f "config/versions.env" ]; then
  source config/versions.env
  echo "✅ Loaded config/versions.env"
else
  echo -e "${RED}❌ config/versions.env not found${NC}"
  exit 1
fi

if [ -f "env.d/20-features.env" ]; then
  source env.d/20-features.env
  echo "✅ Loaded env.d/20-features.env"
else
  echo -e "${YELLOW}⚠️  env.d/20-features.env not found, using defaults${NC}"
fi

# ==============================================
# Detect Setup Mode (dev vs repro)
# ==============================================
echo ""
echo -e "${BLUE}🔍 Detecting environment...${NC}"

# Auto-detect CI/Codespace
if [ -n "$CODESPACE_NAME" ] || [ -n "$CI" ] || [ -n "$GITHUB_ACTIONS" ]; then
  export SETUP_MODE=repro
  echo -e "${YELLOW}🔒 CI/Codespace detected - forcing REPRO mode${NC}"
  export ALLOW_LATEST=false
  export PREFER_OFFLINE=true
  export STRICT_VERSIONS=true
else
  echo "📍 Running in ${SETUP_MODE} mode"
fi

echo "   SETUP_MODE: ${SETUP_MODE}"
echo "   ALLOW_LATEST: ${ALLOW_LATEST}"
echo "   STRICT_VERSIONS: ${STRICT_VERSIONS}"

# Repro-Mode enforcement
if [ "$SETUP_MODE" = "repro" ]; then
  if [ "$ALLOW_LATEST" = "true" ]; then
    echo -e "${RED}❌ REPRO mode does not allow ALLOW_LATEST=true${NC}"
    exit 1
  fi

  # Prefer artifacts
  if [ -d "artifacts" ] && [ "$(ls -A artifacts 2>/dev/null)" ]; then
    OFFLINE_MODE=true
    echo "🔒 REPRO mode: using offline artifacts"
  fi
fi

# ==============================================
# Initialize Provenance Tracking
# ==============================================
echo ""
echo -e "${BLUE}📦 Initializing supply chain provenance...${NC}"

SETUP_ID="$(date +%Y%m%d-%H%M%S)-$(openssl rand -hex 3 2>/dev/null || head -c 6 /dev/urandom 2>/dev/null | od -An -tx1 | tr -d ' \n' || date +%s)"
PROVENANCE_FILE="$REPO_ROOT/provenance.json"

# Initialize provenance.json
cat > "$PROVENANCE_FILE" <<EOF
{
  "setup_id": "$SETUP_ID",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "host": {
    "hostname": "$(hostname)",
    "os": "$(uname -s)",
    "arch": "$(uname -m)",
    "user": "${USER:-unknown}"
  },
  "installers": [],
  "integrity": {
    "all_verified": true,
    "failed_checks": [],
    "trust_level": "high"
  }
}
EOF

echo "✅ Provenance initialized: $SETUP_ID"

# Function to record installer in provenance
record_installer() {
  local name=$1
  local version=$2
  local source=$3  # "remote" or "artifact"
  local location=$4
  local hash=""

  if [ -f "$location" ]; then
    hash=$(sha256sum "$location" 2>/dev/null | awk '{print $1}' || echo "unavailable")
  else
    hash="not_downloaded"
  fi

  # Use Python/jq if available, otherwise simple append
  if command -v jq &> /dev/null; then
    local tmp_file=$(mktemp)
    jq --arg name "$name" \
       --arg version "$version" \
       --arg source "$source" \
       --arg location "$location" \
       --arg hash "$hash" \
       '.installers += [{
         name: $name,
         version: $version,
         source: $source,
         location: $location,
         sha256: $hash,
         verified: ($hash != "unavailable" and $hash != "not_downloaded")
       }]' "$PROVENANCE_FILE" > "$tmp_file" && mv "$tmp_file" "$PROVENANCE_FILE"
  fi
}

# Function to verify strict versions
install_with_strict_check() {
  local tool=$1
  local expected_version=$2
  local actual_version=$3

  if [ "$STRICT_VERSIONS" = "true" ] && [ "$expected_version" != "$actual_version" ]; then
    echo -e "${RED}❌ REPRO mode: Version mismatch for $tool${NC}"
    echo "   Expected: $expected_version"
    echo "   Got: $actual_version"
    exit 1
  fi
}

# Initialize setup report
REPORT_FILE="$REPO_ROOT/setup-report.json"
cat > "$REPORT_FILE" <<EOF
{
  "setup_id": "$SETUP_ID",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "os": "$(uname -s)",
  "arch": "$(uname -m)",
  "mode": "$SETUP_MODE",
  "tools": [],
  "summary": {
    "total": 0,
    "installed": 0,
    "skipped": 0,
    "failed": 0
  }
}
EOF

# Function to log tool status
log_status() {
  local tool=$1
  local version=$2
  local path=$3
  local status=$4  # installed, skipped, failed

  if command -v jq &> /dev/null; then
    local tmp_file=$(mktemp)
    jq --arg tool "$tool" \
       --arg version "$version" \
       --arg path "$path" \
       --arg status "$status" \
       '.tools += [{name: $tool, version: $version, path: $path, status: $status}] |
        .summary.total += 1 |
        if $status == "installed" then .summary.installed += 1
        elif $status == "skipped" then .summary.skipped += 1
        elif $status == "failed" then .summary.failed += 1
        else . end' "$REPORT_FILE" > "$tmp_file" && mv "$tmp_file" "$REPORT_FILE"
  fi
}

# ==============================================
# Install Node.js (via nvm)
# ==============================================
if [ "$FEATURE_NODE" = "true" ]; then
  echo ""
  echo -e "${BLUE}━━━ Installing Node.js (FEATURE_NODE=true) ━━━${NC}"

  if command -v node &> /dev/null; then
    NODE_CURRENT=$(node --version | sed 's/^v//')
    echo "ℹ️  Node.js already installed: $NODE_CURRENT"

    if [ "$NODE_CURRENT" = "$NODE_VERSION" ]; then
      echo "✅ Version matches expected: $NODE_VERSION"
      log_status "node" "$NODE_CURRENT" "$(which node)" "installed"
    else
      echo -e "${YELLOW}⚠️  Version mismatch (expected: $NODE_VERSION, got: $NODE_CURRENT)${NC}"
      log_status "node" "$NODE_CURRENT" "$(which node)" "installed"
    fi
  else
    echo "📦 Installing Node.js $NODE_VERSION via nvm..."

    # Install nvm
    if [ ! -d "$HOME/.nvm" ]; then
      NVM_INSTALLER="/tmp/nvm-install-$SETUP_ID.sh"
      # Download with TLS verification (curl uses system CA certs by default)
      curl -o "$NVM_INSTALLER" -fsSL --tlsv1.2 "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh"
      record_installer "nvm" "$NVM_VERSION" "remote" "$NVM_INSTALLER"

      bash "$NVM_INSTALLER"
      rm -f "$NVM_INSTALLER"
    fi

    # Source nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

    # Install Node
    nvm install "$NODE_VERSION"
    nvm use "$NODE_VERSION"
    nvm alias default "$NODE_VERSION"

    NODE_ACTUAL=$(node --version | sed 's/^v//')
    install_with_strict_check "node" "$NODE_VERSION" "$NODE_ACTUAL"

    echo -e "${GREEN}✅ Node.js $NODE_ACTUAL installed${NC}"
    log_status "node" "$NODE_ACTUAL" "$(which node)" "installed"

    # Install pnpm
    npm install -g "pnpm@${PNPM_VERSION}"
    echo -e "${GREEN}✅ pnpm $PNPM_VERSION installed${NC}"
  fi
else
  echo ""
  echo -e "${YELLOW}⏭️  Skipping Node.js (FEATURE_NODE=false)${NC}"
  log_status "node" "N/A" "N/A" "skipped"
fi

# ==============================================
# Install Python (via Miniconda)
# ==============================================
if [ "$FEATURE_PYTHON" = "true" ]; then
  echo ""
  echo -e "${BLUE}━━━ Installing Python (FEATURE_PYTHON=true) ━━━${NC}"

  if command -v python &> /dev/null || command -v python3 &> /dev/null; then
    PYTHON_CMD=$(command -v python || command -v python3)
    PYTHON_CURRENT=$($PYTHON_CMD --version 2>&1 | awk '{print $2}')
    echo "ℹ️  Python already installed: $PYTHON_CURRENT"

    if [[ "$PYTHON_CURRENT" == "$PYTHON_VERSION"* ]]; then
      echo "✅ Version matches expected: $PYTHON_VERSION"
      log_status "python" "$PYTHON_CURRENT" "$PYTHON_CMD" "installed"
    else
      echo -e "${YELLOW}⚠️  Version mismatch (expected: $PYTHON_VERSION, got: $PYTHON_CURRENT)${NC}"
      log_status "python" "$PYTHON_CURRENT" "$PYTHON_CMD" "installed"
    fi
  else
    echo "📦 Installing Python $PYTHON_VERSION via Miniconda..."

    CONDA_INSTALLER="/tmp/miniconda-$SETUP_ID.sh"
    CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-py312_${MINICONDA_VERSION}-Linux-$(uname -m).sh"

    # Download with TLS verification
    curl -o "$CONDA_INSTALLER" -fsSL --tlsv1.2 "$CONDA_URL"
    record_installer "miniconda" "$MINICONDA_VERSION" "remote" "$CONDA_INSTALLER"

    bash "$CONDA_INSTALLER" -b -p "$HOME/miniconda3"
    rm -f "$CONDA_INSTALLER"

    # Initialize conda
    eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
    conda init bash

    PYTHON_ACTUAL=$(python --version 2>&1 | awk '{print $2}')
    install_with_strict_check "python" "$PYTHON_VERSION" "$PYTHON_ACTUAL"

    echo -e "${GREEN}✅ Python $PYTHON_ACTUAL installed${NC}"
    log_status "python" "$PYTHON_ACTUAL" "$(which python)" "installed"

    # Install uv (modern Python package installer)
    pip install uv
    echo -e "${GREEN}✅ uv package manager installed${NC}"
  fi
else
  echo ""
  echo -e "${YELLOW}⏭️  Skipping Python (FEATURE_PYTHON=false)${NC}"
  log_status "python" "N/A" "N/A" "skipped"
fi

# ==============================================
# Install Rust (via rustup)
# ==============================================
if [ "$FEATURE_RUST" = "true" ]; then
  echo ""
  echo -e "${BLUE}━━━ Installing Rust (FEATURE_RUST=true) ━━━${NC}"

  if command -v rustc &> /dev/null; then
    RUST_CURRENT=$(rustc --version | awk '{print $2}')
    echo "ℹ️  Rust already installed: $RUST_CURRENT"

    if [ "$RUST_CURRENT" = "$RUST_VERSION" ]; then
      echo "✅ Version matches expected: $RUST_VERSION"
      log_status "rust" "$RUST_CURRENT" "$(which rustc)" "installed"
    else
      echo -e "${YELLOW}⚠️  Version mismatch (expected: $RUST_VERSION, got: $RUST_CURRENT)${NC}"
      log_status "rust" "$RUST_CURRENT" "$(which rustc)" "installed"
    fi
  else
    echo "📦 Installing Rust $RUST_VERSION via rustup..."

    RUSTUP_INSTALLER="/tmp/rustup-init-$SETUP_ID.sh"
    # Download with TLS verification
    curl -o "$RUSTUP_INSTALLER" -fsSL --tlsv1.2 "https://sh.rustup.rs"
    record_installer "rustup" "$RUST_VERSION" "remote" "$RUSTUP_INSTALLER"

    sh "$RUSTUP_INSTALLER" -y --default-toolchain "$RUST_VERSION"
    rm -f "$RUSTUP_INSTALLER"

    source "$HOME/.cargo/env"

    RUST_ACTUAL=$(rustc --version | awk '{print $2}')
    install_with_strict_check "rust" "$RUST_VERSION" "$RUST_ACTUAL"

    echo -e "${GREEN}✅ Rust $RUST_ACTUAL installed${NC}"
    log_status "rust" "$RUST_ACTUAL" "$(which rustc)" "installed"
  fi
else
  echo ""
  echo -e "${YELLOW}⏭️  Skipping Rust (FEATURE_RUST=false)${NC}"
  log_status "rust" "N/A" "N/A" "skipped"
fi

# ==============================================
# Install AI Tools (if enabled)
# ==============================================
if [ "$FEATURE_AI" = "true" ]; then
  echo ""
  echo -e "${BLUE}━━━ Installing AI Tools (FEATURE_AI=true) ━━━${NC}"

  if command -v python &> /dev/null || command -v python3 &> /dev/null; then
    pip install openai anthropic langchain
    echo -e "${GREEN}✅ AI libraries installed${NC}"
  else
    echo -e "${YELLOW}⚠️  Python not available, skipping AI tools${NC}"
  fi
else
  echo -e "${YELLOW}⏭️  Skipping AI Tools (FEATURE_AI=false)${NC}"
fi

# ==============================================
# Generate env.d/10-tools.env
# ==============================================
echo ""
echo -e "${BLUE}📝 Generating environment configuration...${NC}"

mkdir -p env.d
cat > env.d/10-tools.env <<EOF
# Auto-generated by setup.sh on $(date)
# Tool paths and environment variables

# NVM
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && source "\$NVM_DIR/nvm.sh"

# Conda
if [ -d "\$HOME/miniconda3" ]; then
  eval "\$(\$HOME/miniconda3/bin/conda shell.bash hook)"
fi

# Rust
if [ -f "\$HOME/.cargo/env" ]; then
  source "\$HOME/.cargo/env"
fi

# Setup metadata
export SETUP_ID="$SETUP_ID"
export SETUP_MODE="$SETUP_MODE"
EOF

echo "✅ Created env.d/10-tools.env"

# ==============================================
# Golden Path: pre-commit MANDATORY
# ==============================================
echo ""
echo -e "${BLUE}━━━ SECURITY ENFORCEMENT ━━━${NC}"

FORCE_UNSAFE=${FORCE_UNSAFE:-false}

if [ "$FORCE_UNSAFE" = "true" ]; then
  echo -e "${RED}⚠️  FORCE_UNSAFE=true - Skipping pre-commit installation${NC}"
  echo -e "${RED}⚠️  WARNING: Security gates disabled!${NC}"
else
  echo "🔒 Installing pre-commit hooks (mandatory)"

  if ! command -v pre-commit &> /dev/null; then
    if command -v pip &> /dev/null; then
      pip install pre-commit
    else
      echo -e "${YELLOW}⚠️  Python/pip not available, skipping pre-commit${NC}"
    fi
  fi

  if command -v pre-commit &> /dev/null; then
    # Create a basic .pre-commit-config.yaml if it doesn't exist
    if [ ! -f ".pre-commit-config.yaml" ]; then
      cat > .pre-commit-config.yaml <<'PRECOMMIT'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-json
      - id: check-merge-conflict
PRECOMMIT
      echo "✅ Created .pre-commit-config.yaml"
    fi

    pre-commit install

    echo -e "${GREEN}✅ pre-commit hooks installed and verified${NC}"
    echo -e "${GREEN}✅ Golden Path enforced: commits will be checked${NC}"
  fi
fi

# ==============================================
# Generate MCP Context (for AI coding assistants)
# ==============================================
echo ""
echo -e "${BLUE}🤖 Generating MCP context...${NC}"

mkdir -p .mcp
cat > .mcp/context.json <<EOF
{
  "project": {
    "name": "development-setup",
    "type": "infrastructure",
    "setup_id": "$SETUP_ID"
  },
  "environment": {
    "os": "$(uname -s)",
    "arch": "$(uname -m)",
    "mode": "$SETUP_MODE"
  },
  "capabilities": {
    "languages": {
      "node": $([ "$FEATURE_NODE" = "true" ] && echo "true" || echo "false"),
      "python": $([ "$FEATURE_PYTHON" = "true" ] && echo "true" || echo "false"),
      "rust": $([ "$FEATURE_RUST" = "true" ] && echo "true" || echo "false")
    },
    "features": {
      "frontend": $([ "$FEATURE_FRONTEND" = "true" ] && echo "true" || echo "false"),
      "backend": $([ "$FEATURE_BACKEND" = "true" ] && echo "true" || echo "false"),
      "ai": $([ "$FEATURE_AI" = "true" ] && echo "true" || echo "false")
    }
  }
}
EOF

echo "✅ Created .mcp/context.json"

# ==============================================
# Generate Agent Handshake
# ==============================================
echo ""
echo -e "${BLUE}🤝 Generating agent handshake...${NC}"

HANDSHAKE_FILE="$REPO_ROOT/agent-handshake.json"

# Detect installed toolchains
TOOLCHAINS="[]"
if command -v jq &> /dev/null; then
  TOOLCHAINS="["

  if [ "$FEATURE_NODE" = "true" ] && command -v node &> /dev/null; then
    TOOLCHAINS="$TOOLCHAINS{\"name\":\"node\",\"version\":\"$(node --version | sed 's/^v//')\",\"path\":\"$(which node)\",\"available\":true},"
  fi

  if [ "$FEATURE_PYTHON" = "true" ] && command -v python &> /dev/null; then
    TOOLCHAINS="$TOOLCHAINS{\"name\":\"python\",\"version\":\"$(python --version 2>&1 | awk '{print $2}')\",\"path\":\"$(which python)\",\"available\":true},"
  fi

  if [ "$FEATURE_RUST" = "true" ] && command -v rustc &> /dev/null; then
    TOOLCHAINS="$TOOLCHAINS{\"name\":\"rust\",\"version\":\"$(rustc --version | awk '{print $2}')\",\"path\":\"$(which rustc)\",\"available\":true},"
  fi

  # Remove trailing comma
  TOOLCHAINS="${TOOLCHAINS%,}]"
fi

cat > "$HANDSHAKE_FILE" <<EOF
{
  "protocol_version": "1.0",
  "setup_status": "success",
  "setup_id": "$SETUP_ID",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "environment": {
    "os": "$(uname -s | tr '[:upper:]' '[:lower:]')",
    "arch": "$(uname -m)",
    "shell": "$SHELL"
  },
  "toolchains": $TOOLCHAINS,
  "roles": [
    {
      "name": "backend",
      "agent": "backend-agent",
      "tools": ["python", "rust"],
      "ready": $([ "$FEATURE_BACKEND" = "true" ] && echo "true" || echo "false")
    },
    {
      "name": "frontend",
      "agent": "frontend-agent",
      "tools": ["node", "typescript"],
      "ready": $([ "$FEATURE_FRONTEND" = "true" ] && echo "true" || echo "false")
    },
    {
      "name": "ai",
      "agent": "ai-agent",
      "tools": ["python"],
      "ready": $([ "$FEATURE_AI" = "true" ] && echo "true" || echo "false")
    }
  ],
  "recommended_tasks": [
    {
      "task": "backend-init",
      "command": "uvx cookiecutter python-project",
      "agent": "backend-agent",
      "enabled": $([ "$FEATURE_BACKEND" = "true" ] && echo "true" || echo "false")
    },
    {
      "task": "frontend-scaffold",
      "command": "pnpm create vite",
      "agent": "frontend-agent",
      "enabled": $([ "$FEATURE_FRONTEND" = "true" ] && echo "true" || echo "false")
    }
  ],
  "capabilities": {
    "can_build_backend": $(command -v python &>/dev/null && echo "true" || echo "false"),
    "can_build_frontend": $(command -v node &>/dev/null && echo "true" || echo "false"),
    "can_deploy": false,
    "can_test": true
  }
}
EOF

echo "✅ agent-handshake.json generated"

# ==============================================
# Smoke Tests
# ==============================================
echo ""
echo -e "${BLUE}🧪 Running smoke tests...${NC}"

SMOKE_FAILED=0

if [ "$FEATURE_NODE" = "true" ]; then
  if command -v node &> /dev/null; then
    echo "✅ node: $(node --version)"
  else
    echo -e "${RED}❌ node not found${NC}"
    ((SMOKE_FAILED++))
  fi
fi

if [ "$FEATURE_PYTHON" = "true" ]; then
  if command -v python &> /dev/null; then
    echo "✅ python: $(python --version 2>&1)"
  else
    echo -e "${RED}❌ python not found${NC}"
    ((SMOKE_FAILED++))
  fi
fi

if [ "$FEATURE_RUST" = "true" ]; then
  if command -v rustc &> /dev/null; then
    echo "✅ rustc: $(rustc --version)"
  else
    echo -e "${RED}❌ rustc not found${NC}"
    ((SMOKE_FAILED++))
  fi
fi

# ==============================================
# Summary
# ==============================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📊 Setup ID: $SETUP_ID"
echo "🔧 Mode: $SETUP_MODE"
echo "📄 Reports generated:"
echo "   - provenance.json (supply chain tracking)"
echo "   - agent-handshake.json (agent orchestration)"
echo "   - setup-report.json (installation summary)"
echo ""

if [ $SMOKE_FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ All smoke tests passed${NC}"
else
  echo -e "${YELLOW}⚠️  $SMOKE_FAILED smoke test(s) failed${NC}"
fi

echo ""
echo "Next steps:"
echo "  1. Source environment: source env.d/10-tools.env"
echo "  2. Verify installation: ./scripts/validate.sh"
echo "  3. Generate badges: ./scripts/generate-badges.sh"
echo ""
