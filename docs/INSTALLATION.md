# Installation Guide

Complete guide for setting up your enterprise development environment.

## Prerequisites

### Required Tools
- **Git**: Version control system
- **Curl/Wget**: For downloading installers
- **Bash** (Linux/macOS) or **PowerShell** (Windows)

### System Requirements
- **Linux**: Ubuntu 20.04+, Debian 11+, or similar
- **macOS**: 11.0 (Big Sur) or later
- **Windows**: Windows 10/11 with PowerShell 5.1+

## Quick Start

### Linux/macOS

```bash
# Clone the repository
git clone https://github.com/eyshoit-commits/setup.git
cd setup

# Validate environment
bash scripts/validate.sh

# Run setup
bash scripts/setup.sh

# Verify installation
bash scripts/smoke-test.sh
```

### Windows

```powershell
# Clone the repository
git clone https://github.com/eyshoit-commits/setup.git
cd setup

# Validate environment
.\scripts\validate.ps1

# Run setup
.\scripts\setup.ps1

# Verify installation
.\scripts\smoke-test.ps1
```

## Detailed Installation

### Step 1: Validation

Before running setup, validate that your environment meets the requirements:

```bash
bash scripts/validate.sh
```

This checks for:
- Required directory structure
- Configuration files
- System tools (git, curl, etc.)

### Step 2: Configuration (Optional)

#### Version Locking

By default, all tool versions are locked in `config/versions.env`. To use the latest versions instead:

```bash
export SETUP_ALLOW_LATEST=true
bash scripts/setup.sh
```

Or create a `.env` file:

```bash
cp .env.example .env
# Edit .env and set SETUP_ALLOW_LATEST=true
```

#### Custom Versions

Edit `config/versions.env` to specify different versions:

```bash
NODE_VERSION=20.11.0
PYTHON_VERSION=3.12.1
RUST_VERSION=1.75.0
PNPM_VERSION=8.15.1
```

### Step 3: Run Setup

The setup script is idempotent - you can run it multiple times safely.

```bash
bash scripts/setup.sh
```

What it does:
1. ✅ Installs nvm (Node Version Manager)
2. ✅ Installs Node.js (version from config)
3. ✅ Installs pnpm (package manager)
4. ✅ Installs Miniconda (Python environment)
5. ✅ Installs uv/uvx (Python tools)
6. ✅ Installs Rust toolchain
7. ✅ Generates environment files (`env.d/`)
8. ✅ Installs pre-commit hooks
9. ✅ Generates MCP context
10. ✅ Runs smoke tests

### Step 4: Verify Installation

After setup completes, verify everything works:

```bash
bash scripts/smoke-test.sh
```

This tests:
- Node.js execution
- Python/uvx functionality
- Rust/Cargo functionality
- pnpm package manager

### Step 5: Review Reports

Setup generates comprehensive reports:

#### Setup Report (`setup-report.json`)
```json
{
  "timestamp": "2026-01-02T12:00:00Z",
  "os": "Linux",
  "arch": "x86_64",
  "tools": [...],
  "summary": {
    "installed": 4,
    "skipped": 2,
    "failed": 0,
    "total": 6
  }
}
```

#### MCP Context (`.mcp/context.json`)
Contains environment metadata for agent-based workflows.

## Offline Installation

For air-gapped or restricted network environments:

### Step 1: Prepare Artifacts

On a machine with internet access:

```bash
mkdir -p artifacts
cd artifacts

# Download NVM
curl -LO https://github.com/nvm-sh/nvm/archive/refs/tags/v0.39.7.tar.gz
mv v0.39.7.tar.gz nvm-0.39.7.tar.gz

# Download Miniconda
curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
mv Miniconda3-latest-Linux-x86_64.sh miniconda.sh

# Download UV installer
curl -LO https://astral.sh/uv/install.sh
mv install.sh uv-installer.sh

# Download Rustup
curl -LO https://sh.rustup.rs
mv sh.rustup.rs rustup-init.sh
```

### Step 2: Transfer to Target

Copy the entire `artifacts/` directory to the target machine.

### Step 3: Run Setup

The setup script automatically detects and uses local artifacts:

```bash
bash scripts/setup.sh
# Will output: "📦 Offline artifacts detected - using local installers"
```

## DevContainer Installation

For GitHub Codespaces or VS Code DevContainers:

The setup runs automatically via `.devcontainer/post-create.sh`. No manual steps needed!

To customize:
1. Edit `.devcontainer/devcontainer.json`
2. Rebuild container: **Cmd/Ctrl+Shift+P** → "Rebuild Container"

## Environment Variables

After installation, source the environment files:

```bash
# Source all environment files
for env_file in env.d/*.env; do
  source "$env_file"
done
```

Or add to your shell profile (`~/.bashrc`, `~/.zshrc`):

```bash
# Setup environment
for env_file in ~/setup/env.d/*.env; do
  [ -f "$env_file" ] && source "$env_file"
done
```

## Post-Installation

### Install Pre-commit Hooks

```bash
cp config/pre-commit-config.yaml .pre-commit-config.yaml
pre-commit install
```

### Verify Tools

```bash
# Node
node --version
pnpm --version

# Python
python --version
uv --version
uvx ruff --version

# Rust
rustc --version
cargo --version
```

## Updating

To update installed tools:

1. Edit `config/versions.env` with new versions
2. Run setup again:
   ```bash
   bash scripts/setup.sh
   ```
3. Tools will be updated if versions changed

## Uninstallation

To remove installed tools:

```bash
# Remove nvm
rm -rf ~/.nvm

# Remove conda
rm -rf ~/miniconda3

# Remove Rust
rustup self uninstall

# Clean environment files
rm -rf env.d/10-tools.env
```

## Next Steps

- Read [SECURITY.md](./SECURITY.md) for security best practices
- Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues
- Review `.opencode/` for agent definitions
- Explore `scripts/` for available automation

## Support

For issues or questions:
- Check the troubleshooting guide
- Review `setup-report.json` for diagnostics
- Open an issue on GitHub
