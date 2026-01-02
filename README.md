# 🚀 Enterprise-Grade Development Environment Setup

> Production-ready setup repository with idempotent installation, version locking, offline support, and multi-agent orchestration.

[![🚀 Codespace Setup](https://github.com/eyshoit-commits/setup/actions/workflows/codespace-setup.yml/badge.svg)](https://github.com/eyshoit-commits/setup/actions/workflows/codespace-setup.yml)
[![🔒 Security Scan](https://github.com/eyshoit-commits/setup/actions/workflows/security-scan.yml/badge.svg)](https://github.com/eyshoit-commits/setup/actions/workflows/security-scan.yml)

## ✨ Features

### 🔄 **Idempotent Installation**
- Run setup multiple times safely without side effects
- Smart version checking with skip logic
- Status summary: `INSTALLED / SKIPPED / FAILED`

### 🔐 **Deterministic Version Locking**
- All tool versions pinned in `config/versions.env`
- No surprises in CI/CD pipelines
- Optional `SETUP_ALLOW_LATEST=true` for development

### 📦 **Offline/Air-gap Support**
- Use `artifacts/` directory for local installers
- Corporate network friendly
- Zero internet dependency option

### 📊 **Machine-Readable Reports**
- `setup-report.json` - Installation status
- `.mcp/context.json` - Agent-ready environment metadata
- Perfect for automation and telemetry

### 🐚 **Shell-Agnostic Environment**
- Centralized `env.d/` configuration
- Bash, Zsh, Fish, PowerShell support
- No more profile spaghetti

### 🔒 **Security-First Approach**
- Pre-commit hooks (ruff, eslint, clippy)
- Gitleaks secret scanning
- Dependency auditing
- `.env` leak prevention

### 🤖 **MCP/Agent-Ready**
- OpenCode agent definitions
- Multi-agent orchestration
- Context-aware workflows

### ✅ **Automated Smoke Tests**
- Post-installation validation
- Tests: Node, Python, Rust, pnpm
- Exit with error on failure

## 🚀 Quick Start

### Linux/macOS

```bash
# Clone and setup
git clone https://github.com/eyshoit-commits/setup.git
cd setup
bash scripts/setup.sh
```

### Windows

```powershell
# Clone and setup
git clone https://github.com/eyshoit-commits/setup.git
cd setup
.\scripts\setup.ps1
```

### GitHub Codespaces

Click "Code" → "Create codespace" - setup runs automatically! ✨

## 📁 Repository Structure

```
setup/
├── .devcontainer/          # DevContainer configuration
├── .github/
│   ├── copilot-instructions.md
│   └── workflows/          # CI/CD pipelines
├── .opencode/              # Agent definitions
│   ├── agents/             # Specialized agents
│   └── skills/             # Reusable skills
├── .mcp/                   # MCP context (generated)
├── scripts/                # Setup automation
│   ├── setup.sh            # Main setup (Bash)
│   ├── setup.ps1           # Main setup (PowerShell)
│   ├── validate.sh         # Pre-flight checks
│   ├── smoke-test.sh       # Post-install validation
│   └── generate-report.sh  # Report generator
├── config/
│   ├── versions.env        # 📌 Version locks
│   ├── .tool-versions      # asdf compatible
│   ├── requirements.txt    # Python dependencies
│   └── pre-commit-config.yaml
├── env.d/                  # Shell-agnostic environment
│   ├── 00-base.env
│   ├── 10-tools.env        # Generated
│   └── 99-custom.env
├── artifacts/              # Offline installers
├── docs/                   # Documentation
│   ├── INSTALLATION.md
│   ├── SECURITY.md
│   └── TROUBLESHOOTING.md
├── .gitleaks.toml          # Secret scanning config
├── setup-report.json       # Generated status report
└── package.json
```

## 🛠️ What Gets Installed

| Tool | Purpose | Version Lock |
|------|---------|--------------|
| **nvm** | Node version manager | ✅ |
| **Node.js** | JavaScript runtime | ✅ |
| **pnpm** | Fast package manager | ✅ |
| **Miniconda** | Python environment | ✅ |
| **uv/uvx** | Fast Python tools | ✅ |
| **Rust** | Systems programming | ✅ |
| **pre-commit** | Git hooks framework | ✅ |

## 📖 Documentation

- **[Installation Guide](docs/INSTALLATION.md)** - Complete setup instructions
- **[Security Policy](docs/SECURITY.md)** - Security features and best practices
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Copilot Instructions](.github/copilot-instructions.md)** - AI development guidelines

## 🔧 Configuration

### Version Locking

Edit `config/versions.env`:

```bash
NODE_VERSION=20.11.0
PYTHON_VERSION=3.12.1
RUST_VERSION=1.75.0
PNPM_VERSION=8.15.1
```

### Allow Latest Versions

```bash
export SETUP_ALLOW_LATEST=true
bash scripts/setup.sh
```

### Offline Installation

1. Download installers to `artifacts/`
2. Run setup (auto-detects and uses local files)

See [INSTALLATION.md](docs/INSTALLATION.md#offline-installation) for details.

## 🤖 Multi-Agent Orchestration

This repository includes OpenCode agent definitions:

- **orchestrator** - Coordinates multi-agent workflows
- **backend-agent** - Python/Rust development
- **frontend-agent** - TypeScript/React development
- **devops-agent** - CI/CD and infrastructure
- **testing-agent** - QA and validation

Agents are context-aware via `.mcp/context.json`.

## 🔒 Security Features

### Pre-commit Hooks

Automatically installed, runs on every commit:

```bash
# Python
ruff check --fix
ruff format

# JavaScript/TypeScript
eslint --fix

# Rust
cargo fmt
cargo clippy
```

### Secret Scanning

Gitleaks runs automatically:
- On every push/PR
- Weekly scheduled scans
- Manual: `gitleaks detect --verbose`

### Dependency Auditing

```bash
# NPM
npm audit

# Python
pip-audit -r config/requirements.txt
```

## 📊 Reports

### Setup Report (`setup-report.json`)

```json
{
  "timestamp": "2026-01-02T12:00:00Z",
  "os": "Linux",
  "tools": [...],
  "summary": {
    "installed": 4,
    "skipped": 2,
    "failed": 0
  },
  "smoke_tests": {
    "node": "passed",
    "python": "passed",
    "rust": "passed"
  }
}
```

### MCP Context (`.mcp/context.json`)

Agent-ready environment metadata for automated workflows.

## 🧪 Testing

```bash
# Validate environment
bash scripts/validate.sh

# Run smoke tests
bash scripts/smoke-test.sh

# Full setup + test
bash scripts/setup.sh && bash scripts/smoke-test.sh
```

## 📦 NPM Scripts

```bash
npm run setup          # Run setup
npm run validate       # Validate environment
npm run test           # Run smoke tests
npm run security:scan  # Run gitleaks
```

## 🌐 Cross-Platform Support

| Platform | Script | Status |
|----------|--------|--------|
| Linux | `scripts/setup.sh` | ✅ Tested |
| macOS | `scripts/setup.sh` | ✅ Tested |
| Windows | `scripts/setup.ps1` | ✅ Tested |
| Codespaces | Auto-setup | ✅ Tested |

## 🤝 Contributing

1. Read [SECURITY.md](docs/SECURITY.md)
2. Check [.github/copilot-instructions.md](.github/copilot-instructions.md)
3. Maintain both Bash and PowerShell versions
4. Test idempotency
5. Update documentation

## 📝 License

MIT

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/eyshoit-commits/setup/issues)
- **Documentation**: [docs/](docs/)
- **Troubleshooting**: [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## ⭐ Features at a Glance

- ✅ Idempotent installation
- ✅ Version locking
- ✅ Offline support
- ✅ JSON reports
- ✅ Shell-agnostic
- ✅ Security scanning
- ✅ MCP/Agent ready
- ✅ Automated tests
- ✅ Cross-platform
- ✅ DevContainer ready
- ✅ GitHub Actions CI
- ✅ Pre-commit hooks

---

**Made with ❤️ for enterprise development teams**
