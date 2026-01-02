#!/bin/bash
# Post-create script - runs once after container is created

set -e

echo "🚀 Running post-create setup..."

# Run the main setup script
bash scripts/setup.sh

# Install development dependencies
echo "📦 Installing development dependencies..."

# Python dev tools
if command -v pip &>/dev/null; then
  pip install -q -r config/requirements.txt || true
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

echo "✅ Post-create setup completed!"
