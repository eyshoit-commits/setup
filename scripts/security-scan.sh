#!/bin/bash
set -euo pipefail

echo "🔒 Running Security Scan..."

# Run npm audit
echo "📦 Checking npm dependencies..."
npm audit --audit-level=moderate

# Check for secrets in code
echo "🔐 Scanning for exposed secrets..."
if command -v gitleaks &> /dev/null; then
    gitleaks detect --verbose
else
    echo "⚠️  gitleaks not installed, skipping secret scan"
fi

# Check file permissions
echo "🔓 Checking file permissions..."
find . -type f -perm /111 -not -path "./.git/*" -not -path "./node_modules/*" -not -path "./scripts/*"

echo "✅ Security scan complete"
