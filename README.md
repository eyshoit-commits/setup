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
