# 🚀 Enterprise-Grade Development Setup

<!-- Auto-generated badges - run ./scripts/generate-badges.sh to update -->
![Status](https://img.shields.io/badge/setup-ready-brightgreen)
![Enterprise](https://img.shields.io/badge/grade-enterprise-blue)
![Supply Chain](https://img.shields.io/badge/supply_chain-tracked-green)
![Agent Ready](https://img.shields.io/badge/agent-ready-purple)

**Blueprint for agentische Softwareentwicklung:**
- ✅ Menschen klicken
- ✅ Maschinen verstehen
- ✅ CI vertraut
- ✅ Security nickt
- ✅ Agents dispatchen Tasks sofort
- ✅ Zero surprises in production

## 🌟 Features

### 1️⃣ Supply Chain Awareness
Track every installer with cryptographic hashes for full transparency and security.

- **Provenance Tracking**: Complete audit trail of all installers
- **SHA-256 Verification**: Cryptographic integrity checking
- **Trust Levels**: Automated assessment of installation security
- **Artifact Caching**: Support for offline/cached installers

📖 [Supply Chain Documentation](docs/SUPPLY-CHAIN.md)

### 2️⃣ Reproducible Builds (Repro Mode)
Deterministic setups for CI/CD and team consistency.

- **Auto-Detection**: CI/Codespace environments automatically use repro mode
- **Strict Versioning**: Exact version matching enforced
- **Offline Support**: Prefer local artifacts over network downloads
- **Drift Detection**: Validate installed versions match expectations

### 3️⃣ Agent Handshake Protocol
Machine-readable environment description for AI agents and automation.

- **Capability Discovery**: What tools and versions are available
- **Role-Based Routing**: Match tasks to appropriate agents
- **Readiness Status**: Know immediately what can be built/tested/deployed
- **Recommended Tasks**: Suggested next steps based on available tools

📖 [Agent Handshake Documentation](docs/AGENT-HANDSHAKE.md)

### 4️⃣ Feature Gates
Fine-grained control over what gets installed.

- **Granular Control**: Enable/disable specific toolchains
- **Role-Based Profiles**: Frontend, backend, AI, DevOps configurations
- **Resource Optimization**: Install only what you need
- **Conditional Installation**: Smart dependency resolution

📖 [Feature Gates Documentation](docs/FEATURE-GATES.md)

### 5️⃣ Drift Detection
Validate environment consistency over time.

- **Version Validation**: Ensure installed versions match configuration
- **Mode-Aware**: Warnings in dev mode, failures in repro mode
- **Comprehensive Checks**: Validates all enabled features
- **Detailed Reporting**: Clear output on any version mismatches

### 6️⃣ Self-Describing Repository
Auto-generated badges and documentation.

- **Badge Generation**: Automatic README badges from setup reports
- **Status Tracking**: Visual indicators of setup health
- **Version Display**: Current tool versions shown in badges
- **CI Integration**: Badges update automatically

### 7️⃣ Golden Path Enforcement
Mandatory security gates with pre-commit hooks.

- **Automatic Installation**: pre-commit hooks installed by default
- **Security First**: Cannot be bypassed without explicit override
- **CI Validation**: GitHub Actions enforce pre-commit checks
- **Quality Gates**: Prevent common issues before commit

## 🚀 Quick Start

### Basic Setup

```bash
# Clone the repository
git clone https://github.com/eyshoit-commits/setup.git
cd setup

# Run setup with default features
./scripts/setup.sh

# Verify installation
./scripts/validate.sh

# Generate README badges
./scripts/generate-badges.sh
```

### Custom Setup with Feature Gates

```bash
# Frontend developer setup
FEATURE_NODE=true FEATURE_FRONTEND=true \
FEATURE_PYTHON=false FEATURE_RUST=false \
./scripts/setup.sh

# Backend developer setup
FEATURE_PYTHON=true FEATURE_RUST=true FEATURE_BACKEND=true \
FEATURE_NODE=false FEATURE_FRONTEND=false \
./scripts/setup.sh

# AI/ML developer setup
FEATURE_PYTHON=true FEATURE_AI=true \
./scripts/setup.sh
```

### Windows Setup

```powershell
# PowerShell
.\scripts\setup.ps1

# Validate
.\scripts\validate.ps1

# Generate badges
.\scripts\generate-badges.ps1
# 🚀 Enterprise Repository Setup

Complete production-ready repository setup with OpenCode Skills, GitHub Marketplace Apps, Enterprise Security Workflows, and Setup Automation.

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/4123d1b055e447648c58627f64af4999)](https://app.codacy.com/gh/eyshoit-commits/setup?utm_source=github.com&utm_medium=referral&utm_content=eyshoit-commits/setup&utm_campaign=Badge_Grade)
[![CodeQL](https://github.com/eyshoit-commits/setup/workflows/CodeQL%20Security%20Analysis/badge.svg)](https://github.com/eyshoit-commits/setup/actions)
[![Snyk](https://github.com/eyshoit-commits/setup/workflows/Snyk%20Security%20Scan/badge.svg)](https://github.com/eyshoit-commits/setup/actions)

## ✨ Features

- 🔐 **Enterprise Security**: CodeQL, Snyk, Codacy security scanning
- 🤖 **AI-Powered Tools**: CodeRabbit, CodiumAI, OpenCode agents
- 📊 **Code Quality**: Automated reviews, coverage tracking, compliance checks
- 🔧 **Automation**: Cross-platform setup scripts, Git hooks, VSCode integration
- 📚 **Documentation**: Comprehensive guides and best practices
# 🚀 Enterprise Setup Repository

> Complete enterprise-grade repository setup with GitHub Marketplace Apps, OpenCode Agents, MCP Integration, and automated workflows.

## Status

### Security
![CodeQL](https://github.com/eyshoit-commits/setup/actions/workflows/security-scan.yml/badge.svg)
![Snyk](https://img.shields.io/badge/Snyk-Monitored-4C4A73?logo=snyk)
![Secret Detection](https://img.shields.io/badge/Secret%20Detection-Active-success)

### Code Quality
![Codacy](https://img.shields.io/badge/Codacy-A-brightgreen?logo=codacy)
![Codecov](https://img.shields.io/badge/Codecov-Active-F01F7A?logo=codecov)
![CodeFactor](https://img.shields.io/badge/CodeFactor-A+-brightgreen?logo=codefactor)
![ShellCheck](https://github.com/eyshoit-commits/setup/actions/workflows/code-quality.yml/badge.svg)

### AI Review
![CodeRabbit](https://img.shields.io/badge/CodeRabbit-Active-blue?logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cGF0aCBkPSJNMTIgMkM2LjQ4IDIgMiA2LjQ4IDIgMTJzNC40OCAxMCAxMCAxMCAxMC00LjQ4IDEwLTEwUzE3LjUyIDIgMTIgMnoiIGZpbGw9IndoaXRlIi8+PC9zdmc+)
![CodiumAI](https://img.shields.io/badge/CodiumAI-Active-blue?logo=ai)

### Infrastructure
![MCP Health](https://github.com/eyshoit-commits/setup/actions/workflows/mcp-health-check.yml/badge.svg)
![Drift Check](https://github.com/eyshoit-commits/setup/actions/workflows/drift-check.yml/badge.svg)
![Setup Validation](https://github.com/eyshoit-commits/setup/actions/workflows/setup-validation.yml/badge.svg)

### Development
![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

---

## 📚 Overview / Übersicht

**English:**  
This repository provides a complete enterprise setup with integrated GitHub Marketplace apps, automated workflows, OpenCode agents, and MCP (Model Context Protocol) server integration. It includes comprehensive security scanning, code quality checks, AI-powered code reviews, and automated testing.

**Deutsch:**  
Dieses Repository bietet ein vollständiges Enterprise-Setup mit integrierten GitHub Marketplace Apps, automatisierten Workflows, OpenCode Agents und MCP (Model Context Protocol) Server-Integration. Es umfasst umfassende Sicherheitsscans, Code-Qualitätsprüfungen, KI-gestützte Code-Reviews und automatisierte Tests.

---

## ✨ Features

### 🔐 Security & Compliance
- **CodeQL Analysis** - Advanced security vulnerability detection
- **Snyk Security Scanning** - Dependency vulnerability monitoring
- **Secret Detection** - Prevent credential leaks with TruffleHog & Gitleaks
- **Dependency Review** - Automated dependency security checks

### 📊 Code Quality
- **Codacy Integration** - Automated code quality analysis
- **Codecov** - Test coverage tracking and reporting
- **CodeFactor** - Code quality scoring
- **ESLint & ShellCheck** - Linting and formatting enforcement

### 🤖 AI-Powered Reviews
- **CodeRabbit AI** - Intelligent PR reviews with contextual suggestions
- **CodiumAI PR Agent** - Automated test generation and code analysis

### 🔄 Workflow Automation
- **Mergify** - Automated merge queue for PRs meeting quality gates
- **Setup Validation** - Repository structure and configuration checks
- **Commit Validation** - Conventional Commits enforcement
- **Drift Detection** - Infrastructure configuration monitoring
- **MCP Health Checks** - Server connectivity and status monitoring

### 🛠️ Development Tools
- **OpenCode Agents** - Bash & PowerShell automation agents
- **MCP Servers** - Filesystem, GitHub, Git, and search integration
- **Git Hooks** - Pre-commit and commit-msg validation
- **Setup Scripts** - Automated environment configuration

---

## 🚀 Quick Start

### Prerequisites
- Node.js v20+
- npm
- Git
- GitHub CLI (recommended)

### Setup

**Unix/Linux/macOS:**
```bash
bash scripts/setup.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\setup.ps1
```

### Validation

```bash
bash scripts/validate-setup.sh
bash scripts/mcp-health-check.sh
```

## 📁 Repository Structure

```
setup/
├── scripts/
│   ├── setup.sh              # Main setup script (Bash)
│   ├── setup.ps1             # Main setup script (PowerShell)
│   ├── validate.sh           # Drift detection (Bash)
│   ├── validate.ps1          # Drift detection (PowerShell)
│   ├── generate-badges.sh    # Badge generator (Bash)
│   └── generate-badges.ps1   # Badge generator (PowerShell)
├── config/
│   └── versions.env          # Tool version configuration
├── env.d/
│   ├── 10-tools.env         # Auto-generated tool paths
│   └── 20-features.env       # Feature gate configuration
├── docs/
│   ├── SUPPLY-CHAIN.md       # Supply chain documentation
│   ├── AGENT-HANDSHAKE.md    # Agent protocol documentation
│   └── FEATURE-GATES.md      # Feature gates documentation
├── .github/workflows/
│   └── enforce-pre-commit.yml # Pre-commit enforcement
├── provenance.json           # Generated: Supply chain tracking
├── agent-handshake.json      # Generated: Agent orchestration
├── setup-report.json         # Generated: Installation summary
└── README-badges.md          # Generated: Badge markdown
```

## 🔧 Configuration

### Version Configuration (`config/versions.env`)

```bash
# Tool versions
NODE_VERSION=20.11.0
PYTHON_VERSION=3.12.1
RUST_VERSION=1.75.0

# Setup mode
SETUP_MODE=dev  # or 'repro' for CI/CD
```

### Feature Gates (`env.d/20-features.env`)

```bash
# Core toolchains
FEATURE_NODE=true
FEATURE_PYTHON=true
FEATURE_RUST=true

# Application domains
FEATURE_FRONTEND=true
FEATURE_BACKEND=true
FEATURE_AI=false
```

## 📊 Generated Artifacts

### Provenance (`provenance.json`)
Complete supply chain tracking with installer hashes.

```json
{
  "setup_id": "20260102-120000-a1b2c3",
  "installers": [...],
  "integrity": {
    "all_verified": true,
    "trust_level": "high"
  }
}
```

### Agent Handshake (`agent-handshake.json`)
Environment capabilities for AI agents.

```json
{
  "protocol_version": "1.0",
  "setup_status": "success",
  "toolchains": [...],
  "capabilities": {
    "can_build_backend": true,
    "can_build_frontend": true
  }
}
```

### Setup Report (`setup-report.json`)
Installation summary and statistics.

```json
{
  "tools": [...],
  "summary": {
    "total": 3,
    "installed": 3,
    "failed": 0
  }
}
```

## 🧪 Validation & Testing

### Drift Detection

```bash
# Run validation
./scripts/validate.sh

# In dev mode: warnings only
# In repro mode: fails on any drift
```

### Smoke Tests

Built into setup script - automatically verifies each installed tool.

### CI Integration

```yaml
# .github/workflows/setup.yml
- name: Run setup
  run: ./scripts/setup.sh
  env:
    SETUP_MODE: repro
    FEATURE_NODE: true

- name: Validate
  run: ./scripts/validate.sh
```

## 🔒 Security

### Golden Path Enforcement

Pre-commit hooks are **mandatory** by default:

```bash
# Bypass only if absolutely necessary
FORCE_UNSAFE=true ./scripts/setup.sh
```

### Supply Chain Security

- All installers tracked with SHA-256 hashes
- Provenance file provides audit trail
- Prefer offline artifacts in repro mode
- Trust level automatically assessed

### CI Pre-Commit Enforcement

GitHub Actions automatically enforce pre-commit checks on all PRs.

## 🤖 Agent Integration

### Reading Capabilities

```python
import json

with open('agent-handshake.json') as f:
    handshake = json.load(f)

if handshake['capabilities']['can_build_backend']:
    # Execute backend tasks
    ...
```

### Role-Based Routing

```bash
# Get appropriate agent for a role
AGENT=$(jq -r '.roles[] | select(.name=="backend") | .agent' agent-handshake.json)
echo "Routing to: $AGENT"
```

## 📚 Documentation

- [Supply Chain Security](docs/SUPPLY-CHAIN.md) - Provenance tracking and integrity
- [Agent Handshake Protocol](docs/AGENT-HANDSHAKE.md) - Agent integration guide
- [Feature Gates](docs/FEATURE-GATES.md) - Configuration and usage

## 🛠️ Troubleshooting

### Setup fails with version mismatch

**Problem**: Installed version doesn't match configuration

**Solution**: Check if running in repro mode unintentionally
```bash
echo $SETUP_MODE  # Should be 'dev' for flexible versioning
```

### Tool not installed despite feature enabled

**Problem**: Feature gate is true but tool missing

**Solution**: Check setup-report.json for errors
```bash
jq '.tools[] | select(.status=="failed")' setup-report.json
```

### Pre-commit blocking commits

**Problem**: Commits failing due to pre-commit checks

**Solution**: Run pre-commit manually to fix issues
```bash
pre-commit run --all-files
```

## 🎯 Success Criteria

- ✅ **provenance.json** with hashes of all installers
- ✅ **SETUP_MODE=repro** for CI/Codespaces
- ✅ **agent-handshake.json** after setup
- ✅ **Feature Gates** in `env.d/20-features.env`
- ✅ **Drift Detection** in validate
- ✅ **README Badge Generator** automatic
- ✅ **pre-commit MANDATORY** (Golden Path)
- ✅ All features in Bash + PowerShell
- ✅ CI Workflows updated
- ✅ Complete documentation

## 🤝 Contributing

1. Fork the repository
2. Enable pre-commit hooks: `pre-commit install`
3. Make your changes
4. Validate: `./scripts/validate.sh`
5. Submit pull request

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

Built for enterprise-grade agentische Softwareentwicklung. Designed to bridge human intuition and machine precision in modern development workflows.

---

**Generated with ❤️ for humans and agents alike**
.
├── .github/          # GitHub Actions workflows & configuration
├── .opencode/        # OpenCode agents & skills configuration
├── .vscode/          # VSCode integration & settings
├── docs/             # Documentation & guides
└── scripts/          # Automation scripts
```

See [SETUP_COMPLETE.md](SETUP_COMPLETE.md) for full details.

## 🔐 Required Secrets

Configure these GitHub secrets for full functionality:

```bash
gh secret set SNYK_TOKEN
gh secret set CODECOV_TOKEN
gh secret set CODACY_PROJECT_TOKEN
gh secret set WAKATIME_API_KEY
```

## 📖 Documentation

- [Setup Completion Guide](SETUP_COMPLETE.md)
- [Recommended Marketplace Apps](docs/RECOMMENDED_MARKETPLACE_APPS.md)
- [Merge Strategy](docs/MERGE_STRATEGY.md)

## 🤖 OpenCode Agents

This repository includes 4 specialized agents:

- **setup-agent**: Automated repository setup and initialization
- **security-agent**: Security scanning and compliance checks
- **roadmap-agent**: Project roadmap management and tracking
- **dev-agent**: Development workflow automation

## 🔍 Security Scanning

Multiple security layers:
- CodeQL for code analysis
- Snyk for dependency scanning
- Codacy for code quality
- Automated compliance checks
- Pre-commit security hooks

## 🎯 Next Steps

1. ✅ Configure GitHub secrets
2. ✅ Enable GitHub Actions
3. ✅ Set up branch protection
4. ✅ Install VSCode extensions
5. ✅ Review agent configurations

## 📄 License

ISC

## 👥 Contributing

Code owners: @eyshoit-commits

See [CODEOWNERS](.github/CODEOWNERS) for detailed ownership rules.
- Git 2.30+
- Node.js 20+
- npm 10+
- GitHub CLI (optional but recommended)

### Installation

```bash
# Clone the repository
git clone https://github.com/eyshoit-commits/setup.git
cd setup

# Run local setup
./scripts/local-setup.sh

# Validate environment
./scripts/validate-environment.sh

# Setup marketplace apps
./scripts/setup-marketplace-apps.sh
```

For Windows (PowerShell):
```powershell
# Run PowerShell setup
.\scripts\setup-marketplace-apps.ps1
```

---

## 📖 Documentation

- **[Setup Guide](docs/SETUP_GUIDE.md)** - Complete setup instructions (DE/EN)
- **[Marketplace Apps](docs/RECOMMENDED_MARKETPLACE_APPS.md)** - App integration guide (DE/EN)
- **[Mergify Configuration](docs/MERGIFY.md)** - Automated merge queue documentation (DE/EN)
- **[Architecture](docs/ARCHITECTURE.md)** - System architecture documentation (DE/EN)

---

## 🔧 Configuration

### Secrets Management
Copy the secrets template and configure your tokens:
```bash
cp .github/secrets-template.env .env
# Edit .env and add your tokens
```

Required secrets for full functionality:
- `SNYK_TOKEN` - Snyk security scanning
- `CODECOV_TOKEN` - Code coverage reporting
- `CODACY_PROJECT_TOKEN` - Code quality analysis
- `GITHUB_TOKEN` - GitHub API access

### Branch Protection
Apply branch protection rules using the configuration:
```bash
# Reference: .github/branch-protection.json
# Apply via GitHub UI: Settings > Branches > Add rule
```

---

## 🔄 Workflows

| Workflow | Trigger | Description |
|----------|---------|-------------|
| [Setup Validation](.github/workflows/setup-validation.yml) | Push, PR | Validates repository structure |
| [Security Scan](.github/workflows/security-scan.yml) | Push, PR, Schedule | CodeQL, Snyk, secret detection |
| [Code Quality](.github/workflows/code-quality.yml) | Push, PR | Codacy, Codecov, linting |
| [AI Review](.github/workflows/ai-review.yml) | PR | CodeRabbit, CodiumAI |
| [MCP Health Check](.github/workflows/mcp-health-check.yml) | Push, Schedule | MCP server monitoring |
| [Drift Check](.github/workflows/drift-check.yml) | Push, Schedule | Configuration drift detection |
| [Commit Validation](.github/workflows/commit-validation.yml) | PR | Conventional Commits validation |
| [Sandbox Test](.github/workflows/sandbox-test.yml) | Push to sandbox/* | Integration testing |

---

## 🤝 Contributing

We follow [Conventional Commits](https://www.conventionalcommits.org/) specification.

Commit message format:
```
type(scope): description

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

---

## 📦 Project Structure

```
setup/
├── .github/
│   ├── workflows/          # GitHub Actions workflows (8 workflows)
│   ├── hooks/              # Git hooks (pre-commit, commit-msg)
│   ├── branch-protection.json  # Branch protection config
│   └── secrets-template.env    # Secrets template
├── .opencode/
│   └── agents/             # OpenCode agent configurations
│       ├── bash-agent.yml
│       └── powershell-agent.yml
├── mcp/
│   └── config.json         # MCP server configuration
├── scripts/
│   ├── setup-marketplace-apps.sh    # Bash setup script
│   ├── setup-marketplace-apps.ps1   # PowerShell setup script
│   ├── validate-environment.sh      # Environment validation
│   └── local-setup.sh               # Local development setup
├── docs/
│   ├── SETUP_GUIDE.md                    # Setup instructions
│   ├── RECOMMENDED_MARKETPLACE_APPS.md   # Marketplace apps guide
│   └── ARCHITECTURE.md                   # Architecture documentation
└── README.md
```

---

## 🔗 Integrated Services

### GitHub Marketplace Apps
- [CodeRabbit](https://github.com/apps/coderabbitai) - AI code reviews
- [CodiumAI](https://github.com/apps/codiumai-pr-agent) - AI PR agent
- [Codacy](https://www.codacy.com/) - Code quality
- [Codecov](https://codecov.io/) - Coverage tracking
- [Snyk](https://snyk.io/) - Security scanning
- [CodeFactor](https://www.codefactor.io/) - Code analysis
- [Mergify](https://mergify.com/) - Automated merge queue

### MCP Servers
- Filesystem Server - File operations
- GitHub Server - GitHub API integration
- Git Server - Git operations
- Brave Search - Documentation lookup

---

## 📝 License

MIT License - see LICENSE file for details

---

## 🌟 Support

- 📖 [Documentation](docs/)
- 🐛 [Issue Tracker](https://github.com/eyshoit-commits/setup/issues)
- 💬 [Discussions](https://github.com/eyshoit-commits/setup/discussions)

---

## 🙏 Acknowledgments

Built with ❤️ using:
- GitHub Actions
- Model Context Protocol (MCP)
- OpenCode Framework
- Industry-leading security and quality tools

---

**Made with 🚀 for Enterprise Development**
