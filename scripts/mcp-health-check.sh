#!/bin/bash
set -euo pipefail

echo "🏥 Running MCP Health Check..."

# Check OpenCode config
if [ -f ".opencode/config.json" ]; then
    echo "✓ OpenCode config present"
    node -e "JSON.parse(require('fs').readFileSync('.opencode/config.json'))" && echo "✓ Valid JSON" || echo "✗ Invalid JSON"
else
    echo "✗ OpenCode config missing"
fi

# Check agents
AGENTS=("setup-agent" "security-agent" "roadmap-agent" "dev-agent")
for agent in "${AGENTS[@]}"; do
    if [ -f ".opencode/agents/$agent.json" ]; then
        echo "✓ $agent"
    else
        echo "✗ $agent missing"
    fi
done

echo "✅ Health check complete"
