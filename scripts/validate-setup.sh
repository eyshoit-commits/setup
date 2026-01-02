#!/bin/bash
set -euo pipefail

echo "🔍 Validating Repository Setup..."

# Check .opencode
[ -f ".opencode/config.json" ] && echo "✓ .opencode/config.json" || echo "✗ .opencode/config.json missing"
[ -f ".opencode/agents/setup-agent.json" ] && echo "✓ setup-agent" || echo "✗ setup-agent missing"
[ -f ".opencode/agents/security-agent.json" ] && echo "✓ security-agent" || echo "✗ security-agent missing"

# Check .github
[ -f ".github/workflows/codeql-analysis.yml" ] && echo "✓ CodeQL workflow" || echo "✗ CodeQL workflow missing"
[ -f ".github/workflows/snyk-security.yml" ] && echo "✓ Snyk workflow" || echo "✗ Snyk workflow missing"
[ -f ".github/dependabot.yml" ] && echo "✓ Dependabot" || echo "✗ Dependabot missing"

# Check scripts
[ -x "scripts/setup.sh" ] && echo "✓ setup.sh executable" || echo "✗ setup.sh not executable"
[ -x "scripts/security-scan.sh" ] && echo "✓ security-scan.sh executable" || echo "✗ security-scan.sh not executable"

echo "✅ Validation complete"
