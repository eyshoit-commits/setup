#!/bin/bash
# Quick setup script for pre-commit hooks

set -e

echo "🔧 Setting up Pre-Commit Hooks..."

# Check if pre-commit is installed
if ! command -v pre-commit &>/dev/null; then
    echo "📦 Installing pre-commit..."
    
    if command -v pip3 &>/dev/null; then
        pip3 install pre-commit
    elif command -v pip &>/dev/null; then
        pip install pre-commit
    else
        echo "❌ Error: pip not found. Please install Python first."
        exit 1
    fi
fi

# Install hooks
echo "📌 Installing Git hooks..."
pre-commit install
pre-commit install --hook-type commit-msg

# Run once to cache environments
echo "🧪 Testing hooks..."
pre-commit run --all-files || true

echo ""
echo "✅ Pre-Commit Hooks aktiviert!"
echo ""
echo "Ab jetzt wird bei jedem Commit automatisch ausgeführt:"
echo "  - Code-Formatierung (Prettier/Black)"
echo "  - Linting (ESLint/Ruff)"
echo "  - Secret-Scanning (Gitleaks)"
echo "  - Commit-Message Validation"
echo ""
echo "💡 Zum Deaktivieren: pre-commit uninstall"
