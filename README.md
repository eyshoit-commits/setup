# 🚀 Enterprise Repository Setup

Complete production-ready repository setup with OpenCode Skills, GitHub Marketplace Apps, Enterprise Security Workflows, and Setup Automation.

[![CodeQL](https://github.com/eyshoit-commits/setup/workflows/CodeQL%20Security%20Analysis/badge.svg)](https://github.com/eyshoit-commits/setup/actions)
[![Snyk](https://github.com/eyshoit-commits/setup/workflows/Snyk%20Security%20Scan/badge.svg)](https://github.com/eyshoit-commits/setup/actions)

## ✨ Features

- 🔐 **Enterprise Security**: CodeQL, Snyk, Codacy security scanning
- 🤖 **AI-Powered Tools**: CodeRabbit, CodiumAI, OpenCode agents
- 📊 **Code Quality**: Automated reviews, coverage tracking, compliance checks
- 🔧 **Automation**: Cross-platform setup scripts, Git hooks, VSCode integration
- 📚 **Documentation**: Comprehensive guides and best practices

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
