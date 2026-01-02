#!/bin/bash
set -e

echo "🚀 Starting Development Container Setup..."

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install additional tools
sudo apt-get install -y curl wget git jq yq ripgrep fd-find bat

# Install package managers
npm install -g pnpm bun

# Install rustup if not already installed
if ! command -v rustup &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

# Install nvm
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Python dependencies with conda
if command -v conda &>/dev/null; then
  if [ -f "config/environment.yml" ]; then
    conda env create -f config/environment.yml || conda env update -f config/environment.yml
    conda activate base
  fi
fi

# Install Python dependencies with pip
if command -v pip &>/dev/null; then
  pip install -r config/requirements.txt
fi

# Install Node dependencies
if [ -f "config/package.json" ]; then
  cd config && pnpm install && cd ..
fi

# Install Rust dependencies
if [ -f "config/Cargo.toml" ]; then
  cd config && cargo build && cd ..
fi

# Setup OpenCode integrations (if script exists)
if [ -f "scripts/opencode/install-integrations.sh" ]; then
  bash scripts/opencode/install-integrations.sh
fi

# Install pre-commit hooks
if command -v pre-commit &>/dev/null; then
  # Copy pre-commit config to root
  cp config/pre-commit-config.yaml .pre-commit-config.yaml 2>/dev/null || true
  pre-commit install || echo "Warning: Could not install pre-commit hooks"
fi

# Setup git config
git config --global core.autocrlf input
git config --global init.defaultBranch main

# Validate setup
if [ -f "scripts/validate.sh" ]; then
  bash scripts/validate.sh
fi

echo "✨ Setup complete! Your development environment is ready."
