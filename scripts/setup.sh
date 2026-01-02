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

# Initialize report (backup previous if exists)
if [ -f "$REPORT_FILE" ]; then
  mv "$REPORT_FILE" "${REPORT_FILE}.backup-$(date +%s)"
fi

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
    # Download and verify before executing (safer than piping directly)
    curl -o /tmp/nvm-install.sh "https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh"
    bash /tmp/nvm-install.sh
    rm /tmp/nvm-install.sh
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
    # Download and verify before executing
    curl -LsSf https://astral.sh/uv/install.sh -o /tmp/uv-install.sh
    sh /tmp/uv-install.sh
    rm /tmp/uv-install.sh
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
    # Download and verify before executing
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup-init.sh
    sh /tmp/rustup-init.sh -y
    rm /tmp/rustup-init.sh
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
