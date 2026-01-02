# Setup Guide

Welcome to the Enterprise Repository Setup! This guide will help you get started with the repository and all its features.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Configuration](#configuration)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## 🔧 Prerequisites

Before you begin, ensure you have the following installed:

### Required

- **Git** (≥ 2.30.0)
  ```bash
  git --version
  ```

- **jq** (for JSON processing)
  ```bash
  # Ubuntu/Debian
  sudo apt-get install jq
  
  # macOS
  brew install jq
  
  # Windows (via Chocolatey)
  choco install jq
  ```

### Recommended

- **GitHub CLI** (`gh`)
  - Download from: https://cli.github.com/
  - Required for branch protection configuration

- **Node.js** (≥ 18.0.0)
  - For JavaScript/TypeScript development
  - Download from: https://nodejs.org/

- **Python** (≥ 3.8)
  - For Python development
  - Download from: https://python.org/

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)

**Linux/macOS:**
```bash
./scripts/setup.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\setup.ps1
```

This will:
1. ✅ Validate prerequisites
2. ✅ Check directory structure
3. ✅ Validate configurations
4. ✅ Configure Git settings
5. ✅ Set up environment
6. ✅ Install agents
7. ✅ Run validation
8. ✅ Generate setup report

### Option 2: Manual Setup

If you prefer manual setup or the automated script fails:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/eyshoit-commits/setup.git
   cd setup
   ```

2. **Verify structure:**
   ```bash
   ./scripts/validate-setup.sh
   ```

3. **Install dependencies:**
   ```bash
   npm install  # If using Node.js
   pip install -r requirements.txt  # If using Python
   ```

4. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your values
   ```

## 📚 Detailed Setup

### 1. Repository Structure

The repository follows this structure:

```
.
├── .opencode/          # OpenCode agent configurations
├── .github/            # GitHub workflows, templates, policies
├── .vscode/            # VSCode settings and agents
├── scripts/            # Automation scripts
├── config/             # Configuration files
└── docs/               # Documentation
```

### 2. OpenCode Agents

The repository includes 13 integrated OpenCode agents:

- **@malhashemi/opencode-skills** - Custom skills and tools
- **@malhashemi/opencode-sessions** - Session management
- **@shuv1337/oc-manager** - Project management
- **@code-yeongyu/oh-my-opencode** - Enhanced features
- **@IgorWarzocha/Opencode-Roadmap** - Roadmap visualization
- **@zenobi-us/opencode-background** - Background processing
- **@Tarquinen/opencode-smart-title** - Smart title generation
- **@pantheon-org/opencode-warcraft-notifications** - Notifications
- **@IgorWarzocha/Opencode-Context-Analysis-Plugin** - Context analysis
- **@shuv1337/oc-web** - Web interface
- **@ajaxdude/opencode-ai-poimandres-theme** - Theme
- **@VoltAgent/awesome-claude-code-subagents** - Subagent patterns
- **@darrenhinde/OpenAgents** - Agent templates

To install agents:
```bash
./scripts/install-agents.sh
```

### 3. GitHub Configuration

#### Workflows

The repository includes 6 automated workflows:

1. **setup-validation.yml** - Validates repository structure
2. **security-scan.yml** - Security vulnerability scanning
3. **mcp-health-check.yml** - MCP configuration validation
4. **drift-check.yml** - Configuration drift detection
5. **commit-validation.yml** - Commit message format validation
6. **dependabot-auto-merge.yml** - Auto-merge dependency updates

#### Branch Protection

To configure branch protection rules:

```bash
./scripts/configure-branch-protection.sh
```

This requires GitHub CLI (`gh`) authentication.

### 4. VSCode Integration

The repository includes VSCode configurations for:

- **Settings** - Editor, formatting, linting
- **Extensions** - Recommended extensions
- **Launch** - Debug configurations
- **Agents** - Dev, Debug, and Test agents

Open the repository in VSCode to automatically apply these settings.

## ⚙️ Configuration

### Environment Variables

Create a `.env` file from the template:

```bash
cp .env.example .env
```

Edit the following variables:

```bash
# GitHub Configuration
GITHUB_TOKEN=your_personal_access_token
GITHUB_OWNER=eyshoit-commits
GITHUB_REPO=setup

# Agent Configuration
OPENCODE_ENABLED=true
AGENT_AUTO_LOAD=true

# Security
SECRET_SCANNING_ENABLED=true
VULNERABILITY_SCANNING_ENABLED=true

# CI/CD
CI_ENVIRONMENT=development
```

### Configuration Files

The `config/` directory contains:

- **agents.config.json** - Agent orchestration settings
- **security.config.json** - Security policies and settings
- **environments.config.json** - Environment-specific configurations

## ✅ Verification

### Run Validation Script

```bash
./scripts/validate-setup.sh
```

This checks:
- ✅ Directory structure
- ✅ Configuration files
- ✅ Workflows
- ✅ Agent configurations
- ✅ Scripts
- ✅ Documentation
- ✅ Issue templates

### Manual Verification

1. **Check Git configuration:**
   ```bash
   git config --list | grep core
   ```

2. **Verify JSON files:**
   ```bash
   find . -name "*.json" -not -path "./node_modules/*" -exec jq empty {} \;
   ```

3. **Test workflows locally:**
   ```bash
   act -l  # If you have 'act' installed
   ```

## 🆘 Troubleshooting

For common issues and solutions, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

### Quick Fixes

**Issue: Permission denied when running scripts**
```bash
chmod +x scripts/*.sh
```

**Issue: jq command not found**
```bash
# Install jq (see Prerequisites section)
```

**Issue: GitHub CLI not authenticated**
```bash
gh auth login
```

**Issue: Invalid JSON in configuration**
```bash
# Find invalid JSON files
find . -name "*.json" -not -path "./node_modules/*" -exec sh -c 'jq empty "$1" 2>&1 | grep -q error && echo "$1"' _ {} \;
```

## 📖 Next Steps

1. Review [AGENTS.md](AGENTS.md) for detailed agent documentation
2. Read [SECURITY-GUIDE.md](SECURITY-GUIDE.md) for security best practices
3. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
4. Review `.github/REPO-POLICY.md` for contribution guidelines

## 🤝 Support

If you need help:

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Search existing [Issues](https://github.com/eyshoit-commits/setup/issues)
3. Create a new issue using the appropriate template
4. Contact @eyshoit-commits

## 📝 License

See the repository license file for details.

---

**Last Updated:** 2026-01-02  
**Version:** 1.0.0
