# Quick Start Guide

Get up and running with Enterprise-Grade Development Setup in minutes.

## 🚀 Installation

### Linux / macOS

```bash
# Clone the repository
git clone https://github.com/eyshoit-commits/setup.git
cd setup

# Run setup with default configuration
./scripts/setup.sh
```

### Windows

```powershell
# Clone the repository
git clone https://github.com/eyshoit-commits/setup.git
cd setup

# Run setup with default configuration
.\scripts\setup.ps1
```

## 📋 What Gets Installed (Default)

With default settings, the setup installs:

- ✅ **Node.js** (v20.11.0) - JavaScript runtime via nvm
- ✅ **Python** (v3.12.1) - Python runtime via Miniconda
- ✅ **Rust** (v1.75.0) - Rust compiler via rustup
- ✅ **pnpm** - Fast Node.js package manager
- ✅ **uv** - Modern Python package installer
- ✅ **pre-commit** - Git hooks for code quality

## 🎨 Customize Your Setup

### Frontend Developer Profile

Install only Node.js and frontend tools:

```bash
FEATURE_NODE=true \
FEATURE_FRONTEND=true \
FEATURE_PYTHON=false \
FEATURE_RUST=false \
./scripts/setup.sh
```

### Backend Developer Profile

Install Python and Rust for backend development:

```bash
FEATURE_PYTHON=true \
FEATURE_RUST=true \
FEATURE_BACKEND=true \
FEATURE_NODE=false \
./scripts/setup.sh
```

### AI/ML Developer Profile

Install Python with AI libraries:

```bash
FEATURE_PYTHON=true \
FEATURE_AI=true \
FEATURE_NODE=false \
FEATURE_RUST=false \
./scripts/setup.sh
```

### Minimal Setup (CI/CD)

Install nothing, just generate tracking files:

```bash
FEATURE_NODE=false \
FEATURE_PYTHON=false \
FEATURE_RUST=false \
./scripts/setup.sh
```

## 📝 Configuration File

For persistent configuration, create a `.env` file:

```bash
# Copy the example
cp .env.example .env

# Edit with your preferences
nano .env

# Run setup (automatically reads .env)
source .env
./scripts/setup.sh
```

## ✅ Verify Installation

```bash
# Check installed versions
./scripts/validate.sh

# View setup report
cat setup-report.json

# Check agent handshake
cat agent-handshake.json

# View supply chain provenance
cat provenance.json
```

## 🎯 Generate Badges

```bash
# Generate README badges
./scripts/generate-badges.sh

# View badges
cat README-badges.md

# Add to your README
cat README-badges.md >> YOUR_README.md
```

## 🔄 Update Tools

To update to new versions:

```bash
# Edit versions
nano config/versions.env

# Re-run setup (idempotent)
./scripts/setup.sh

# Verify changes
./scripts/validate.sh
```

## 🧪 Test Environment

After setup, test your environment:

```bash
# Source the environment
source env.d/10-tools.env

# Test Node.js
node --version
npm --version
pnpm --version

# Test Python
python --version
pip --version
uv --version

# Test Rust
rustc --version
cargo --version
```

## 🚨 Troubleshooting

### Setup fails

```bash
# Check for errors in the output
./scripts/setup.sh 2>&1 | tee setup.log

# Review the log
less setup.log
```

### Version mismatch

```bash
# Check if in REPRO mode
echo $SETUP_MODE

# Switch to dev mode for flexible versioning
SETUP_MODE=dev ./scripts/setup.sh
```

### Pre-commit blocking commits

```bash
# Run pre-commit manually
pre-commit run --all-files

# Fix any issues, then commit again
git commit -m "your message"
```

## 🎓 Next Steps

1. **Read the Documentation**
   - [Supply Chain Security](docs/SUPPLY-CHAIN.md)
   - [Agent Handshake Protocol](docs/AGENT-HANDSHAKE.md)
   - [Feature Gates](docs/FEATURE-GATES.md)

2. **Configure for Your Team**
   - Create role-based profiles
   - Set up CI/CD workflows
   - Document your setup process

3. **Enable Advanced Features**
   - Add Docker support: `FEATURE_DOCKER=true`
   - Enable Kubernetes: `FEATURE_K8S=true`
   - Try mobile development: `FEATURE_MOBILE=true`

## 💡 Tips

- **Idempotent**: Safe to run setup multiple times
- **Feature Gates**: Only install what you need
- **Repro Mode**: Automatically enabled in CI/CD
- **Supply Chain**: All installers tracked with hashes
- **Agent Ready**: Generate machine-readable environment info

## 🤝 Getting Help

- 📖 [Full Documentation](README.md)
- 🐛 [Report Issues](https://github.com/eyshoit-commits/setup/issues)
- 💬 [Discussions](https://github.com/eyshoit-commits/setup/discussions)
- 📝 [Contributing Guide](CONTRIBUTING.md)

---

**Ready to build? Let's go! 🚀**
