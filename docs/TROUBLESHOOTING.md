# Troubleshooting Guide

Common issues and solutions for the enterprise setup environment.

## Installation Issues

### Setup fails with permission errors

**Problem**: Permission denied when running scripts

**Solution**:
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Or run with bash explicitly
bash scripts/setup.sh
```

### Tools not found after installation

**Problem**: Installed tools not available in PATH

**Solution**:
```bash
# Restart terminal or source environment
source env.d/10-tools.env

# Or source all env files
for env_file in env.d/*.env; do
  source "$env_file"
done

# Add to shell profile for persistence
echo 'for env_file in ~/setup/env.d/*.env; do [ -f "$env_file" ] && source "$env_file"; done' >> ~/.bashrc
```

### nvm: command not found

**Problem**: nvm not loaded in shell

**Solution**:
```bash
# Load nvm manually
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Add to shell profile
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
```

### Conda initialization issues

**Problem**: Conda commands not available

**Solution**:
```bash
# Initialize conda manually
~/miniconda3/bin/conda init bash

# For zsh
~/miniconda3/bin/conda init zsh

# Restart terminal
```

### Rust installation fails

**Problem**: Rustup installation errors

**Solution**:
```bash
# Manual installation
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Source Cargo environment
source "$HOME/.cargo/env"

# Check installation
rustc --version
cargo --version
```

## Version Lock Issues

### Want to use latest versions instead of locked

**Problem**: Setup installs old versions

**Solution**:
```bash
# Set environment variable
export SETUP_ALLOW_LATEST=true
bash scripts/setup.sh

# Or create .env file
echo "SETUP_ALLOW_LATEST=true" > .env
bash scripts/setup.sh
```

### Version conflicts between tools

**Problem**: Different tools require different Node versions

**Solution**:
```bash
# Use nvm to switch versions
nvm install 18
nvm use 18

# Or use specific version for command
nvm exec 18 node app.js

# Create .nvmrc for project
echo "18.0.0" > .nvmrc
nvm use
```

### Cannot update to newer version

**Problem**: Setup skips installation of newer version

**Solution**:
```bash
# Update version in config
nano config/versions.env
# Change: NODE_VERSION=20.11.0 to NODE_VERSION=20.12.0

# Remove old installation (if needed)
rm -rf ~/.nvm/versions/node/v20.11.0

# Run setup again
bash scripts/setup.sh
```

## Offline Mode Issues

### Offline mode not working

**Problem**: Setup still tries to download from internet

**Solution**:
```bash
# Check artifacts directory
ls -la artifacts/

# Ensure files exist and have correct names:
# - nvm-{version}.tar.gz
# - miniconda.sh
# - uv-installer.sh
# - rustup-init.sh

# Verify offline detection
bash scripts/setup.sh
# Should show: "📦 Offline artifacts detected"
```

### Wrong installer architecture

**Problem**: Installer for wrong CPU architecture

**Solution**:
```bash
# Check your architecture
uname -m
# x86_64 = Intel/AMD 64-bit
# arm64 or aarch64 = ARM 64-bit

# Download correct Miniconda:
# Linux x86_64
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O artifacts/miniconda.sh

# macOS arm64 (M1/M2)
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -O artifacts/miniconda.sh
```

## Security Issues

### Pre-commit hooks fail

**Problem**: Commit blocked by pre-commit hooks

**Solution**:
```bash
# Fix issues reported by hooks
# For Python:
ruff check --fix .
ruff format .

# For JavaScript:
eslint --fix .

# For Rust:
cargo fmt
cargo clippy --fix

# If urgent, bypass (not recommended):
git commit --no-verify
```

### Gitleaks reports false positive

**Problem**: Gitleaks flags non-secret as secret

**Solution**:
```bash
# Add to .gitleaks.toml allowlist
# Edit .gitleaks.toml and add:
[allowlist]
paths = [
  "path/to/file.js"
]

# Or use inline comment
# gitleaks:allow
API_KEY = "fake-key-for-testing"
```

### Cannot install pre-commit

**Problem**: pip install pre-commit fails

**Solution**:
```bash
# Install with conda
conda install -c conda-forge pre-commit

# Or use uvx
uvx pre-commit install

# Verify installation
pre-commit --version
```

## Report Issues

### setup-report.json not generated

**Problem**: No report file after setup

**Solution**:
```bash
# Check for jq installation
command -v jq || sudo apt install jq  # Linux
command -v jq || brew install jq      # macOS

# Run setup again
bash scripts/setup.sh

# Manually generate report
bash scripts/generate-report.sh
```

### MCP context not created

**Problem**: .mcp/context.json missing

**Solution**:
```bash
# Create directory
mkdir -p .mcp

# Run setup again
bash scripts/setup.sh

# Verify generation
cat .mcp/context.json | jq .
```

## Smoke Test Failures

### Node smoke test fails

**Problem**: Node command not found

**Solution**:
```bash
# Check nvm installation
ls -la ~/.nvm

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node
nvm install 20
nvm use 20

# Verify
node --version
```

### Python/uvx smoke test fails

**Problem**: uvx or ruff not found

**Solution**:
```bash
# Check uv installation
which uv

# Install if missing
curl -LsSf https://astral.sh/uv/install.sh | sh

# Add to PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Test
uvx ruff --version
```

### Rust smoke test fails

**Problem**: Cargo not found

**Solution**:
```bash
# Check Rust installation
ls -la ~/.cargo

# Source Cargo environment
source "$HOME/.cargo/env"

# Reinstall if needed
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Verify
cargo --version
```

### pnpm smoke test fails

**Problem**: pnpm store path errors

**Solution**:
```bash
# Install pnpm
npm install -g pnpm

# Verify installation
pnpm --version

# Test store
pnpm store path
```

## Windows-Specific Issues

### PowerShell execution policy

**Problem**: Scripts blocked by execution policy

**Solution**:
```powershell
# Check current policy
Get-ExecutionPolicy

# Set to RemoteSigned (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or bypass for single script
powershell -ExecutionPolicy Bypass -File scripts\setup.ps1
```

### nvm-windows installation

**Problem**: nvm not available on Windows

**Solution**:
```powershell
# Install nvm-windows manually
# Download from: https://github.com/coreybutler/nvm-windows/releases
# Run installer: nvm-setup.exe

# Verify
nvm version

# Install Node
nvm install 20
nvm use 20
```

### Line ending issues

**Problem**: Scripts fail due to CRLF line endings

**Solution**:
```bash
# Configure git
git config --global core.autocrlf input

# Convert existing files
dos2unix scripts/*.sh

# Or in git
git add --renormalize .
```

## Performance Issues

### Setup takes too long

**Problem**: Installation is slow

**Solution**:
```bash
# Use offline mode (fastest)
# Download artifacts once, reuse multiple times

# Skip unchanged tools
# Setup is idempotent, skips already installed tools

# Parallel installation (advanced)
# Manually run tool installations in parallel terminals
```

### Large download sizes

**Problem**: Miniconda download is huge

**Solution**:
```bash
# Use Miniforge (smaller alternative)
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O artifacts/miniconda.sh

# Or use system Python + venv
python3 -m venv .venv
source .venv/bin/activate
```

## Getting More Help

### Check logs

```bash
# Run setup with verbose output
bash -x scripts/setup.sh 2>&1 | tee setup.log

# Check specific tool logs
cat ~/.nvm/.nvm.log
cat ~/.cargo/.install.log
```

### Validate environment

```bash
# Run validation script
bash scripts/validate.sh

# Check environment variables
env | grep -E "(NVM|CONDA|CARGO|PATH)"

# Check installed versions
node --version
python --version
rustc --version
```

### Clean slate

```bash
# Remove all installations (nuclear option)
rm -rf ~/.nvm
rm -rf ~/miniconda3
rm -rf ~/.cargo
rm -rf env.d/10-tools.env

# Start fresh
bash scripts/setup.sh
```

### Report bugs

If none of the above helps:

1. Check existing GitHub issues
2. Run diagnostic: `bash scripts/validate.sh > diagnostic.txt`
3. Collect setup report: `cat setup-report.json`
4. Open new issue with:
   - OS and version
   - Error messages
   - diagnostic.txt
   - setup-report.json

## Still Stuck?

- Review [INSTALLATION.md](./INSTALLATION.md)
- Check [SECURITY.md](./SECURITY.md)
- Read `.github/copilot-instructions.md`
- Open a GitHub issue with diagnostic info
